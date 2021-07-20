const { Schema, model } = require('mongoose')

const TokenSchema = new Schema({
    _id : { type: String, required: true },
    token: { type: String, required: true },
    device_type: { type: String, required: true },
    created_at: { type: Date, set: d => convertSecsToMs(d), required: true }
})

const TokenModel = model('Token', TokenSchema)

module.exports = TokenModel