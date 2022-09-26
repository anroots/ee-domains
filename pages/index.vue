<template>
  <div>
    <h1 class="mt-5">.ee domains</h1>
    <p class="lead">This is a plain-text list of all .ee internet domains.</p>
    <p>The list is compiled from the <a href="https://www.internet.ee/domeenid/ee-tsoonifail">.ee AXFR zone file</a>
      once
      a day.
      It does not include any subdomains. The primary purpose of the list is to help (ethical) internet researchers
      obtain
      a "clean" list of domains in a format suitable for immediate use.</p>
    <h2>
      Download <code>.ee</code> domain lists
    </h2>

    <table class="table table-striped table-hover">
      <thead class="thead-dark">
        <tr>
          <th>File name</th>
          <th>Description</th>
          <th>Last update</th>
          <th>Download</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>domains</code></td>
          <td>full list of all
            <code>.ee</code> domains (~6MB)
          </td>
          <td>{{ lastUpdate }}</td>
          <td>
            <a href="/lists/domains.txt">.txt</a> |
            <a href="/lists/domains.json">.json</a>
          </td>
        </tr>
        <tr>
          <td><code>added</code></td>
          <td>list of new domains that were added during the last update</td>
          <td>{{ lastUpdate }}</td>
          <td>
            <a href="/lists/added.txt">.txt</a> |
            <a href="/lists/added.json">.json</a>
          </td>
        </tr>
        <tr>
          <td><code>deleted</code></td>
          <td>list of removed domains that
            deleted during the last update</td>
          <td>{{ lastUpdate }}</td>
          <td>
            <a href="/lists/deleted.txt">.txt</a> |
            <a href="/lists/deleted.json">.json</a>
          </td>
        </tr>
        <tr>
          <td><code>last-update</code></td>
          <td>UNIX timestamp on when
            the lists were last updated</td>
          <td>{{ lastUpdate }}</td>
          <td>
            <a href="/lists/last-update.txt">.txt</a> |
            <a href="/lists/last-update.json">.json</a>
          </td>
        </tr>
      </tbody>
    </table>

    <p>You can download the lists directly using cURL or any other HTTP client. As a matter of courtesy, please include a
      descriptive <code>User-Agent</code> header when doing this repeatedly. There are no uptime
      / API freeze guarantees.</p>

      <h2>Recent timeline</h2>
      <p>Older entries are located <a href="https://github.com/anroots/ee-domains/tree/master/public/lists">here</a></p>
      <month-changelog :year="currentYear" :month="currentMonth"></month-changelog>
      <month-changelog :year="recentYear" :month="recentMonth"></month-changelog>

  </div>
</template>
<script>
import last from '../data/last-update.json';
export default {
  data() {
    return {
      lastUpdate: "(loading...)"
    }
  },
  computed: {
    recentYear() {
      return moment().subtract(1, 'month').year()
    },
    recentMonth() {
      return moment().subtract(1, 'month').format('MM')
    },
    currentYear() {
      return moment().year()
    },
    currentMonth() {
      return moment().format('MM')
    }
  },
  mounted() {
      let last_updated = moment.unix(last[0]);
      this.lastUpdate = last_updated.format('YYYY-MM-DD HH:mm');
  }
}
</script>