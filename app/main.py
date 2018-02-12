from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    return jsonify('Success')


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=80)
