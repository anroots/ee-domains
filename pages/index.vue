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
          <td>list of domains that
            were deleted during the last update</td>
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
        <tr>
          <td><code>first-1000</code></td>
          <td>First 1k domains from <code>domains</code>, alphabetic order</td>
          <td>{{ lastUpdate }}</td>
          <td>
            <a href="/lists/first-1000.txt">.txt</a> |
            <a href="/lists/first-1000.json">.json</a>
          </td>
        </tr>
        <tr>
          <td><code>domains-meta</code></td>
          <td><code>domains</code>, with high-level metadata. Newline delimited JSON. Experimental.</td>
          <td>Twice per month</td>
          <td>
            <a href="https://cdn.ee-domains.sqroot.eu/lists/domains-meta.json">.json</a>
          </td>
        </tr>
      </tbody>
    </table>

    <p>You can download the lists directly using cURL or any other HTTP client. As a matter of courtesy, please include a
      descriptive <code>User-Agent</code> header when doing this repeatedly. There are no uptime
      / API freeze guarantees.</p>

      <h4>Note</h4>
      <ul>
        <li>The list is <a href="https://github.com/anroots/ee-domains/actions">updated once per day</a></li>
        <li>Domains without NS records won't be reflected in the list</li>
      </ul>
      <h2>Recent timeline</h2>
      <p>Changes in the .ee register within the past 2 months. Older entries are located <a href="https://github.com/anroots/ee-domains/tree/master/public/lists">here</a>.</p>
      
      <month-changelog :year="currentYear" :month="currentMonth"></month-changelog>
      <month-changelog :year="recentYear" :month="recentMonth"></month-changelog>

  </div>
</template>
<script>
import last from '../data/last-update.json';
import { DateTime } from 'luxon';

export default {
  data() {
    return {
      lastUpdate: "(loading...)"
    }
  },
  computed: {
    recentYear() {
      return DateTime.now().minus({months: 1}).toFormat('yyyy')
    },
    recentMonth() {
      return DateTime.now().minus({months: 1}).toFormat('MM')
    },
    currentYear() {
      return DateTime.now().toFormat('yyyy')
    },
    currentMonth() {
      return DateTime.now().toFormat('MM')
    }
  },
  mounted() {
      let last_updated = DateTime.fromSeconds(parseInt(last[0]));
      this.lastUpdate = last_updated.toFormat('yyyy-MM-dd HH:mm');
  }
}
</script>