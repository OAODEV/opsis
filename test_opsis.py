import main
import os


class MockResponse:
    def __init__(self, text):
        self.text = text


def test_can_pass():
    assert True


def test_health_endpoint(client):
    response = client.get('/health').json
    assert response == {'health': 'OK'}


def test_raw_results_chart(client, monkeypatch):
    test_uri = "mockfrlocv1mockquery"

    def mock_requests_get(uri, headers={}):
        return MockResponse('{"a": 1}')

    monkeypatch.setattr(main.requests, 'get', mock_requests_get)
    monkeypatch.setattr(os.environ, 'get', lambda x, y: "./test_charts")
    response = client.get(
        "/v1/raw-results-test?formatted_results_location={}".format(test_uri),
    ).json

    assert response == 1
