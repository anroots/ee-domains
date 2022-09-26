<template>
    <h3>{{ monthName }} {{ year }}</h3>

    <div class="container" v-if="loaded">
        <div class="row align-items-start" v-for="(dayEntry, day) in this.changelog" :key="day">
            <h4>{{ day }}</h4>
            <ul class="lh-1" v-for="added in dayEntry.added" :key="added">
                <li><span class="badge text-bg-success">+</span> <a :href="`https://${added}`">{{ added }}</a></li>
            </ul>
            <ul class="lh-1" v-for="deleted in dayEntry.deleted" :key="deleted">
                <li><span class="badge text-bg-danger">-</span> {{ deleted }}</li>
            </ul>
        </div>
    </div>
    <p v-else>Loading...</p>
</template>
<script>
import axios from 'axios'
export default {
    data(){
        return {
            changelog: [],
            loaded: false
        }
    },
    props: {
        year: { type: String, required: true },
        month: { type: String, required: true },
    },
    computed: {
        monthName() {
            return moment().month(this.month).format('MMMM')
        }
    },
    mounted () {
        self = this
        axios
        .get(`/lists/${this.year}/${this.month}.json`)
        .then(response => {this.changelog = response.data; this.loaded = true})
  }
}
</script>
