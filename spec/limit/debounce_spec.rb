require 'spec_helper'
require 'thread_safe'

describe Debounce do
  describe '.debounce' do
    it 'prevents the given block from executing until calls have ceased for at least the given time' do
      results = ThreadSafe::Array.new
      RateLimit.debounce(0.01, :test) { results << 0 }
      RateLimit.debounce(0.01, :test) { results << 1 }
      RateLimit.debounce(0.01, :test) { results << 2 }
      expect(results).to eq []
      sleep 0.015
      expect(results).to eq [2]
      RateLimit.debounce(0.01, :test) { results << 3 }
      RateLimit.debounce(0.01, :test) { results << 4 }
      expect(results).to eq [2]
      sleep 0.015
      expect(results).to eq [2, 4]
    end

    it 'only runs the last block sent within a time period' do
      result = nil
      99.times do |i|
        RateLimit.debounce(0.01, :test) { raise "##{i + 1} got run instead of the last" }
      end
      RateLimit.debounce(0.01, :test) { result = :success }
      sleep 0.015
      expect(result).to eq :success
    end

    describe 'namespacing' do
      it 'namespaces the debouncer based on the arguments passed' do
        results = ThreadSafe::Array.new
        RateLimit.debounce(0.01, :one) { results << 1 }
        RateLimit.debounce(0.01, :two) { results << 0 }
        RateLimit.debounce(0.01, :two) { results << 2 }
        sleep 0.015
        expect(results).not_to include 0
        expect(results).to include 1
        expect(results).to include 2
      end

      it 'requires at least one namespace argument' do
        expect { RateLimit.debounce(0.01) }.to raise_error ArgumentError
      end
    end

    describe 'threadsafety' do
      it 'enqueues long-running blocks rather than running them concurrently, to avoid thread safety issues'

      it 'runs blocks concurrently if one of the arguments to debounce is :threadsafe'
    end

    it 'takes a minimal time to execute, so these specs can sleep 0.01 and not have issues' do
      count = 0
      start = Time.now
      RateLimit.debounce(0.01, :test) { count += 1 }
      expect(Time.now - start).to be < 0.001
    end
  end
end
