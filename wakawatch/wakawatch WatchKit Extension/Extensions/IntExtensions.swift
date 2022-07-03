extension Int {
    func isSuccessfulHttpResponseCode() -> Bool {
        return self >= 200 && self <= 299
    }
}
