mongooseFactory = require '../src'
unionized = require 'unionized'
{expect} = require 'chai'
mongoose = require 'mongoose'

describe 'named factory', ->

  describe 'an unnamed factory', ->
    beforeEach ->
      @Puppy = mongoose.model 'Puppy', mongoose.Schema
        name: { type: String, required: true }

      mongooseFactory @Puppy

    it 'sets a default name', (done) ->
      unionized.build 'puppy', (err, puppy) =>
        expect(err).not.to.be.ok
        expect(puppy).to.be.an.instanceOf @Puppy
        expect(puppy.name).to.be.ok
        done()

  describe 'a named factory', ->
    beforeEach ->
      mongooseFactory 'fido', @Puppy

    it 'uses the name', (done) ->
      unionized.build 'fido', (err, puppy) ->
        expect(err).not.to.be.ok
        expect(puppy).to.be.an.instanceOf Puppy
        expect(puppy.name).to.be.ok
        done()


