class DbEntriesController < ShikimoriController
  before_action :authenticate_user!, only: %i[edit edit_field update]

  # it must be always before :fetch_resource
  before_action { og page_title: resource_klass.model_name.human }
  before_action :fetch_resource, if: :resource_id
  before_action :og_db_entry_meta, if: :resource_id

  COLLETIONS_PER_PAGE = 4

  def tooltip
    og noindex: true
  end

  def versions
    @collection = @resource.parameterized_versions
  end

  def collections
    return redirect_to @resource.url, status: 301 if @resource.collections_scope.none?

    og noindex: true, page_title: t('in_collections')

    page = [params[:page].to_i, 1].max

    @collection = Collections::Query.fetch(locale_from_host)
      .where(id: @resource.collections_scope)
      .paginate(page, COLLETIONS_PER_PAGE)
      .transform do |collection|
        Topics::TopicViewFactory
          .new(true, true)
          .build(collection.maybe_topic(locale_from_host))
      end
  end

  def edit
    og noindex: true, page_title: i18n_t('entry_edit')
  end

  def edit_field
    og noindex: true, page_title: i18n_t('entry_edit')
    @field = params[:field]

    authorize! :create, temp_verison
    authorize! :major_change, temp_verison if major_fields.include? @field
    authorize! :minor_change, temp_verison if minor_fields.include? @field

    render template: 'db_entries/edit_field'
  end

  def update
    if (update_params.keys & major_fields).any?
      authorize! :major_change, temp_verison
    end

    if (update_params.keys & minor_fields).any?
      authorize! :minor_change, temp_verison
    end

    Version.transaction do
      @version =
        if update_params[:image]
          update_image
        elsif update_params[:external_links]
          update_external_links
        else
          update_version
        end

      authorize! :create, @version
    end

    if @version.persisted?
      redirect_to(
        @resource.edit_url,
        notice: i18n_t("version_#{@version.state}")
      )
    else
      redirect_back(
        fallback_location: @resource.edit_url,
        alert: @version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

  def sync
    authorize! :sync, @resource

    MalParsers::FetchEntry.perform_async(
      @resource.mal_id,
      @resource.object.class.name.downcase
    )
    Rails.cache.write [:anime, :sync, @resource.id], true, expires_in: 1.hour

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('sync_scheduled')
    )
  end

private

  def og_db_entry_meta
    if @resource.object.respond_to?(:description_ru)
      og description: @resource.description_meta
    end
    og image: ImageUrlGenerator.instance.url(@resource, :original)
  end

  def major_fields
    @resource.object.class::SIGNIFICANT_MAJOR_FIELDS.select do |field|
      field != 'image' || @resource.image.exists?
    end
  end

  def minor_fields
    @resource.object.class::SIGNIFICANT_MINOR_FIELDS.select do |field|
      field != 'image' || @resource.image.exists?
    end
  end

  def update_version
    version = Versioneers::FieldsVersioneer
      .new(@resource.object)
      .premoderate(
        update_params.is_a?(Hash) ? update_params : update_params.to_unsafe_h,
        current_user,
        params[:reason]
      )

    version.auto_accept if version.persisted? && can?(:auto_accept, version)
    version
  end

  def update_image
    versioneer = Versioneers::PostersVersioneer.new(@resource.object)

    version = versioneer.premoderate(
      update_params[:image],
      current_user,
      params[:reason]
    )

    version.auto_accept if version.persisted? && can?(:auto_accept, version)
    version
  end

  def update_external_links
    version = Versioneers::CollectionVersioneer
      .new(@resource.object, :external_links)
      .premoderate(
        update_params[:external_links].map(&:to_unsafe_h),
        current_user,
        params[:reason]
      )

    version.auto_accept if version.persisted? && can?(:auto_accept, version)
    version
  end

  def temp_verison
    Version.new(
      user: current_user,
      item: @resource.decorated? ? @resource.object : @resource,
      item_diff: {
        @field => []
      },
      state: 'pending'
    )
  end
end
