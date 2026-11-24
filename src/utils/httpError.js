exports.httpError = (status, message) => Object.assign(new Error(message), { status });
