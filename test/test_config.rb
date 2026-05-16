# frozen_string_literal: true

require "test_helper"

class TestConfig < Minitest::Test
  def test_default_config_has_correct_types
    config = TailwindMerge::Config::DEFAULTS

    assert_equal(500, config[:cache_size])
    assert(config[:ignore_empty_cache])
    refute(config[:nonexistent])
    assert_equal("block", config[:class_groups]["display"].first)
    assert_equal("auto", config[:class_groups]["overflow"].first["overflow"].first)
    refute(config[:class_groups]["overflow"].first[:nonexistent])
  end

  def test_custom_config_is_not_mutated
    config = {
      theme: {
        "spacing" => ["my-space"],
      },
    }

    TailwindMerge::Merger.new(config:)

    assert_equal({ theme: { "spacing" => ["my-space"] } }, config)
  end

  def test_custom_theme_does_not_leak_into_default_config
    custom_merger = TailwindMerge::Merger.new(config: {
      theme: {
        "spacing" => ["my-space"],
      },
    })
    default_merger = TailwindMerge::Merger.new

    assert_equal("p-my-space", custom_merger.merge("p-3 p-my-space"))
    assert_equal("p-my-space p-3", default_merger.merge("p-my-space p-3"))
  end
end
