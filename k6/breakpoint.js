import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    stages: [
        { duration: '2h', target: 20000 },
    ],
};

const PROMETHEUS_ENDPOINT = 'http://metric-prometheus-9bc1c5bca73884e8.elb.ap-northeast-2.amazonaws.com/api/v1/query';
const PROMETHEUS_QUERY = 'sum by (instance, job) (rate(kubelet_http_requests_total[1h]))'; // 예시 쿼리, 실제 사용 시 적절한 Prometheus 쿼리로 대체 필요

export default function () {
    const params = {
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
    };

    const body = `query=${encodeURIComponent(PROMETHEUS_QUERY)}`;

    const res = http.post(PROMETHEUS_ENDPOINT, body, params);

    check(res, {
        'is status 200': (r) => r.status === 200,
        'is result not empty': (r) => JSON.parse(r.body).data.result.length > 0,
    });

    console.log(JSON.stringify(res.body));

    sleep(1); // 각 VU 사이의 딜레이, 초 단위
}
