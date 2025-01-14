const LINKED_TYPE_USER_SELECT = '.topic-linked select.type';

pageLoad('topics_new', 'topics_edit', 'topics_create', 'topics_update', () => {
  const $form = $('.b-form.edit_topic, .b-form.new_topic');
  if (!$form.length) { return; }

  const $topicLinked = $('#topic_linked', $form);
  const $linkedType = $('#topic_linked_type', $form);
  const $topicLink = $('.topic-link', $form);

  const initialLinkedType = $('#topic_linked_type').val() ||
    $('option', LINKED_TYPE_USER_SELECT).val();

  $(LINKED_TYPE_USER_SELECT)
    .on('change', ({ currentTarget }) => {
      const { value } = currentTarget;
      const loweredValue = value.toLowerCase();

      $linkedType.val(value);
      $topicLinked
        .data('autocomplete', $topicLinked.data(`${loweredValue}-autocomplete`))
        .attr('placeholder', $topicLinked.data(`${loweredValue}-placeholder`))
        .trigger('flushCache');
    })
    .val(initialLinkedType)
    .trigger('change');

  $('.b-shiki_editor', $form).shikiEditor();
  $('#topic_forum_id', $form).trigger('change');

  $('.topic-linked .remove', $form).on('click', e => {
    e.preventDefault();

    $topicLink.find('a').remove();
    $('#topic_linked_id', $form).val('');
    // $('#topic_linked_type', $form).val('');
    $('#topic_linked', $form).val('');

    $topicLinked.show();
    $(LINKED_TYPE_USER_SELECT).show();
    $topicLink.hide();
  });

  // выбор привязанного к топику
  $topicLinked.completable()
    .on('autocomplete:success', ({ currentTarget }, entry) => {
      const pluralLinkedType = `${$linkedType.val().toLowerCase()}s`.replace('ranobes', 'ranobe');

      currentTarget.value = '';

      $('#topic_linked_id', $form).val(entry.id);
      $('#topic_linked_type', $form).val($linkedType.val());

      $topicLink.find('a').remove();
      $topicLink.prepend(`
        <a href='/${pluralLinkedType}/${entry.id}' class='bubbled b-link'>
          ${entry.name}
        </a>
      `);
      $topicLink.process();

      $topicLinked.hide();
      $(LINKED_TYPE_USER_SELECT).hide();
      $('.topic-link', $form).show();
    })
    .on('keypress', e => {
      if ((e.keyCode === 10) || (e.keyCode === 13)) {
        e.preventDefault();
      }
    });
});
