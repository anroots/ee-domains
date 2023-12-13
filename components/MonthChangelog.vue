<template>
    <h3>{{ monthName }} {{ year }}</h3>

    <div class="container" v-if="loaded">
        <div class="accordion" :id="`accordion-${year}-${month}`">

            <div class="accordion-item" v-for="(dayEntry, day) in this.changelog" :key="day">
                <h2 class="accordion-header">
                    <button class="accordion-button" type="button" data-bs-toggle="collapse"
                        :data-bs-target="`#collapse-${year}-${month}-${day}`">
                        {{ day }} {{ monthName }} {{ year }}
                    </button>
                </h2>
                <div :id="`collapse-${year}-${month}-${day}`" class="accordion-collapse collapse"
                    :data-bs-parent="`#accordion-${year}-${month}`">
                    <div class="accordion-body">
                        <div class="row align-items-start">
                            <div class="row align-items-start">
                                <div class="col">
                                    <ul class="lh-1" v-for="added in dayEntry.added" :key="added">
                                        <li><span class="badge text-bg-success">+</span>&nbsp;<a :href="`https://${added}`"
                                                target="_blank">{{ added
                                                }}</a></li>
                                    </ul>
                                </div>

                                <div class="col">
                                    <ul class="lh-1" v-for="deleted in dayEntry.deleted" :key="deleted">
                                        <li><span class="badge text-bg-danger">-</span>&nbsp;
                                            <a :href="`https://web.archive.org/web/*/${deleted}`" target="_blank">{{ deleted
                                            }}</a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>
    <p v-else>Loading...</p>
</template>
<script>
import axios from 'axios'
export default {
    data() {
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
            // .month() accepts range of 0..11
            return moment().year(this.year).month(this.month - 1).format('MMMM')
        }
    },
    mounted() {
        self = this
        axios
            .get(`/lists/${this.year}/${this.month}.json`)
            .then(response => { this.changelog = response.data; this.loaded = true })
    }
}
</script>
