mongooseFactory = require '../src'
{expect} = require 'chai'
mongoose = require 'mongoose'
fibrous = require 'fibrous'

describe 'mongoose-factory', ->

  describe 'a mongoose model', ->
    kittySchema = mongoose.Schema
      name:
        type: String
        required: true
      adorableness: Number
      paws: [
        nickname: String
        clawCount: Number
      ]
    Kitten = mongoose.model 'Kitten', kittySchema

    it 'generates a factory', fibrous ->
      kitten = mongooseFactory(Kitten).sync.json 'paws[]': 4
      expect(kitten).to.have.property 'name'
      expect(kitten.adorableness).to.be.within(0, 100)
      expect(kitten.paws).to.have.length 4
      expect(kitten.paws[1]).to.have.property 'nickname'
      expect(kitten.paws[1]).to.have.property 'clawCount'
