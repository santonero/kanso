# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::FormFieldSkeletonComponent, type: :component do
  it "renders a single skeleton by default" do
    render_inline(described_class.new)
    expect(page).to have_css(".animate-pulse", count: 1)
  end

  it "renders multiple skeletons when specified" do
    render_inline(described_class.new(fields: 3))
    expect(page).to have_css(".animate-pulse", count: 3)
  end
end
