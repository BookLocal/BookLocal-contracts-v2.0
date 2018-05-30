function getAddressFromTxEvent(transaction) {
    assert.isObject(transaction);
    let logs = transaction.logs;
    assert.equal(logs.length, 1, 'too many logs found!');
    return logs[0].args['hotelAddress'];
}

Object.assign(exports, {
    getAddressFromTxEvent
})
