let uniq_id = 987654321;
const new_id = () => uniq_id += 1;

const has_duplicate = (links, link) =>
  links.some(v =>
    (v !== link) &&
      (v.linked_id === link.linked_id) &&
      (v.group === link.group)
  )
;

const no_links_to_fill = (links, group) =>
  links.none(v => (v.group === group) && !v.linked_id)
;

module.exports = {
  state: {
    collection: {}
  },

  actions: {
    fillLink(context, { link, changes }) {
      context.commit('FILL_LINK', { link, changes });

      if (has_duplicate(context.state.collection.links, link)) {
        context.commit('REMOVE_LINK', link);
      }

      if (no_links_to_fill(context.state.collection.links, link.group)) {
        context.commit('ADD_LINK', { group: link.group });
      }
    },

    addLink(context, data) { context.commit('ADD_LINK', data); },
    removeLink(context, data) { context.commit('REMOVE_LINK', data); },
    moveLink(context, data) { context.commit('MOVE_LINK', data); },
    renameGroup(context, data) { context.commit('RENAME_GROUP', data); },
    refill(context, data) { context.commit('REFILL', data); }
  },

  mutations: {
    ADD_LINK(state, link_data) {
      const link = Object.add(link_data, {
        group: null,
        linked_id: null,
        name: null,
        text: '',
        url: null,
        key: new_id()
      }, { resolve: false });

      if (link.linked_id && has_duplicate(state.collection.links, link)) { return; }

      const last_in_group = state.collection.links
        .filter(v => v.group === link.group)
        .last();
      const index = state.collection.links.indexOf(last_in_group);

      if (index !== -1) {
        state.collection.links.splice(index + 1, 0, link);
      } else {
        state.collection.links.push(link);
      }
    },

    REMOVE_LINK(state, link) {
      state.collection.links.splice(
        state.collection.links.indexOf(link),
        1
      );
    },

    MOVE_LINK(state, { from_index, to_index, group_index }) {
      const { group } = state.collection.links[group_index];
      const from_element = state.collection.links.splice(from_index, 1)[0];

      if (from_element.group !== group) { from_element.group = group; }

      if (!has_duplicate(state.collection.links,from_element)) {
        state.collection.links.splice(to_index, 0, from_element);
      }
    },

    RENAME_GROUP(state, { from_name, to_name }) {
      state.collection.links.forEach(function(link) {
        if (link.group === from_name) {
          link.group = to_name;
        }
      });
    },

    FILL_LINK(state, { link, changes }) {
      Object.forEach(changes, (value, key) => link[key] = value);
    },

    REFILL(state, data) {
      state.collection.links = data;
    }
  },

  getters: {
    collection(store) { return store.collection; },
    links(store) { return store.collection.links; },
    groups(store) { return store.collection.links.map(v => v.group).unique(); },
    groupedLinks(store) { return store.collection.links.groupBy(v => v.group); }
  },

  modules: {}
};