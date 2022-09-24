import { defineNuxtConfig } from 'nuxt'

// https://v3.nuxtjs.org/api/configuration/nuxt.config
export default defineNuxtConfig({
    "target":"static",
    "css": [
        "~/assets/scss/main.scss"
    ],
    modules: [
        '@nuxtjs/sitemap'
      ],
})
