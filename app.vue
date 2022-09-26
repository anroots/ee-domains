<template>
  <div>
    <main role="main" class="col-lg-8 mx-auto p-4 py-md-5">
      <NuxtPage />
    </main>

    <footer class="footer">
      <div class="container text-center">
        <small>
          <span class="text-muted"><a href="https://github.com/anroots/ee-domains">GitHub</a> | Abuse and contact - ando
            at sqroot dot eu</span>
        </small>
      </div>
    </footer>
  </div>

</template>
<script>

export default {
  head() {
    return {
      htmlAttrs: {
        lang: 'ee'
      },
      title: 'ee-domains',
      meta: [
        { name: 'description', content: 'Changelog of Estonian domains' },
        { name: 'keywords', content: 'axfr,eesti domeenid,estonian domains list' }
      ],
      script: [
        {
          src: "https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js",
        },
        { src: "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js" }
      ]
    }
  }
}
</script>