import time
import socket
import requests
from typing import List
import urllib3


class DomainScanner:

    domain: str
    html: str
    cert_issue: None
    timeout: int = 5
    headers: dict = {
        'User-Agent': ''
    }

    parked_patterns: List[str] = [
        'NB! Your domain has been registered but has NOT yet been linked to a hosting service',
        'Thank you for choosing our hosting services! We strive to provide you with impeccable service and make our services as easy to use as possible.',
        'Next to our secure domain ownership transfer process, we strictly monitor all transactions.',
        'Mina olen Veebimajutuse rebane ning tervitan teid siin tühjal veebilehel.'
    ]

    def __init__(self, domain: str) -> None:
        self.domain = domain
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    def scan(self) -> dict:

        result = {
            'domain': self.domain,
            'ip': None,
            'timestamp': round(time.time()),
            'is_parked': None,
            'cert_issue': None,
            'is_empty': None,
            'has_webserver': False
        }
        try:
            result['ip'] = socket.getaddrinfo(self.domain, 80)[0][4][0]
        except:
            return result
        result['has_webserver'] = self.load_html()

        if result['has_webserver']:
            result['is_parked'] = self.is_parked()
            result['is_empty'] = len(self.html.strip()) < 2
            result['cert_issue'] = self.cert_issue
        return result

    def is_parked(self) -> bool:
        for parked_pattern in self.parked_patterns:
            if parked_pattern in self.html:
                return True
        return False

    def load_html(self) -> bool:
        try:
            r = requests.get(f'http://{self.domain}',
                             verify=True, allow_redirects=True, timeout=self.timeout, headers=self.headers)
            self.cert_issue = False
        except requests.exceptions.SSLError:
            self.cert_issue = True
            r = requests.get(f'http://{self.domain}',
                             verify=False, allow_redirects=True, timeout=self.timeout, headers=self.headers)
        except:
            return False

        self.html = r.text
        return r.status_code >= 200 and r.status_code < 600


def scan_domain(domain: str) -> dict:
    return DomainScanner(domain).scan()
