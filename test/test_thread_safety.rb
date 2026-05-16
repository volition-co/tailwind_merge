# frozen_string_literal: true

require "test_helper"

class TestThreadSafety < Minitest::Test
  def test_merger_uses_thread_safe_cache
    merger = TailwindMerge::Merger.new

    assert_instance_of(LruRedux::ThreadSafeCache, merger.instance_variable_get(:@cache))
  end

  # rubocop:disable ThreadSafety/NewThread
  def test_same_merger_can_be_used_from_multiple_threads
    merger = TailwindMerge::Merger.new
    examples = {
      "p-1 p-2" => "p-2",
      "hover:block hover:inline" => "hover:inline",
      "text-sm leading-6 text-lg" => "text-lg",
      "non-tailwind inline block" => "non-tailwind block",
      ["m-1", "m-2", nil, "px-4"] => "m-2 px-4",
    }
    errors = Queue.new

    threads = Array.new(8) do
      Thread.new do
        100.times do
          examples.each do |input, expected|
            actual = merger.merge(input)
            errors << [input, expected, actual] unless actual == expected
          end
        end
      end
    end
    threads.each(&:join)

    failure = errors.pop unless errors.empty?

    assert_nil(failure, "unexpected merge result from thread: #{failure.inspect}")
  end
  # rubocop:enable ThreadSafety/NewThread
end
