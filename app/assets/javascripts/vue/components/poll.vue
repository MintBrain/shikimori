<template lang='pug'>
  .block
    input(
      type='hidden'
      name='poll[variants_attributes][]'
      v-if='isEmpty'
    )
    .b-nothing_here(
      v-if='!collection.length'
    )
      | {{ I18n.t('frontend.poll_variants.nothing_here') }}
    draggable.block(
      v-bind='dragOptions'
      v-model='collection'
      v-if="collection.length"
    )
      .b-collection_item.single-line(
        v-for='pollVariant in collection'
      )
        .delete(
          @click='remove(pollVariant)'
        )
        .drag-handle
        .b-input
          input(
            type='text'
            name='poll[variants_attributes][][label]'
            v-model='pollVariant.label'
            :placeholder="I18n.t('frontend.poll_variants.label')"
            @keydown.enter='submit'
            @keydown.8='removeEmpty(pollVariant)'
            @keydown.esc='removeEmpty(pollVariant)'
          )

    .b-button(
      @click='add'
    ) {{ I18n.t('actions.add') }}
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

import draggable from 'vuedraggable';
import delay from 'delay';

export default {
  name: 'Poll',
  components: { draggable },
  data() {
    return {
      dragOptions: {
        group: 'poll_variants',
        handle: '.drag-handle'
      }
    };
  },
  computed: {
    ...mapGetters([
      'isEmpty'
    ]),
    collection: {
      get() {
        return this.$store.state.collection;
      },
      set(items) {
        this.$store.dispatch('replace', items);
      }
    }
  },
  methods: {
    ...mapActions([
      'remove'
    ]),
    add() {
      this.$store.dispatch('add', { label: '' });
      this.focusLast();
    },
    submit(e) {
      if (!e.metaKey && !e.ctrlKey) {
        e.preventDefault();
        this.add();
      }
    },
    removeEmpty(pollVariant) {
      if (Object.isEmpty(pollVariant.label) && this.$store.state.collection.length > 1) {
        this.remove(pollVariant);
        this.focusLast();
      }
    },
    async focusLast() {
      // do not use this.$nextTick. it passes "backspace" event to focused input
      await delay();
      $('input', this.$el).last().focus();
    }
  }
};
</script>

<style scoped lang='sass'>
  .b-nothing_here
    margin-bottom: 15px
</style>
