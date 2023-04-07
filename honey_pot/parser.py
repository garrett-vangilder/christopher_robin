from werkzeug.exceptions import BadRequest


class RequestParser:
    """
    This class is used to parse the request object from Flask.
    """

    def __init__(self, request):
        self.request = request

    def parse(self) -> dict:
        """
        This method parses the request object from Flask and returns a dictionary.
        :return: dict
        """
        data = {}
        # Try to parse the request object from Flask
        try:
            data = {
                "headers": dict(self.request.headers),
                "method": self.request.method,
                "args": dict(self.request.args),
                "form": dict(self.request.form),
                "json": self.request.json,
                "cookies": self.request.cookies,
                "files": self.request.files,
                "remote_addr": self.request.remote_addr,
                "url": self.request.url,
                "full_path": self.request.full_path,
                "query_string": self.request.query_string,
            }
        except BadRequest:
            data = {
                "headers": dict(self.request.headers),
                "method": self.request.method,
                "args": dict(self.request.args),
                "form": dict(self.request.form),
                "json": {},
                "cookies": self.request.cookies,
                "files": self.request.files,
                "remote_addr": self.request.remote_addr,
                "url": self.request.url,
                "full_path": self.request.full_path,
                "query_string": self.request.query_string,                
            }

        return data
