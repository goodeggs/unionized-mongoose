mongooseFactory = require '../src'
unionized = require 'unionized'
{expect} = require 'chai'
mongoose = require 'mongoose'

describe 'named factory', ->

  Puppy = mongoose.model 'Puppy', mongoose.Schema
    name: { type: String, required: true }

  describe 'an unnamed factory', ->
    beforeEach ->
      mongooseFactory Puppy

    it 'sets a default name', (done) ->
      unionized.build 'puppy', (err, puppy) ->
        expect(err).not.to.be.ok
        expect(puppy).to.be.an.instanceOf Puppy
        expect(puppy.name).to.be.ok
        done()

  describe 'a named factory', ->
    beforeEach ->
      mongooseFactory 'fido', Puppy

    it 'uses the name', (done) ->
      unionized.build 'fido', (err, puppy) ->
        expect(err).not.to.be.ok
        expect(puppy).to.be.an.instanceOf Puppy
        expect(puppy.name).to.be.ok
        done()


