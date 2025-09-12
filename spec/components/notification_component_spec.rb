# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kanso::NotificationComponent, type: :component do
  described_class::THEMES.each do |theme_name, theme_data|
    context "when the theme is :#{theme_name}" do
      let(:message) { "This is a test message." }
      let(:theme) { theme_name }
      let(:notification_container) { page.find('[data-controller="kanso--notification"]') }

      context "with a title" do
        let(:title) { "Test Title" }
        before { render_inline(described_class.new(message: message, title: title, theme: theme)) }

        it "renders the title and message" do
          expect(notification_container).to have_css("h3", text: title)
          expect(notification_container).to have_css("p", text: message)
        end

        it "applies the correct styling to title and message" do
          expect(notification_container).to have_css("h3[class*='#{theme_data.title_text_classes.split.first}']")
          expect(notification_container).to have_css("p[class*='#{theme_data.body_text_classes.split.first}']")
        end

        it "renders accessibility contracts and icon correctly" do
          icon_wrapper = notification_container.find("div.rounded-full")
          icon_element = icon_wrapper.find("svg")

          expect(notification_container['role']).to eq("alert")
          expect(icon_element['data-icon-name']).to eq(theme_data.icon_name)
          expect(icon_wrapper['class']).to include(*theme_data.icon_bg_classes.split)
        end
      end

      context "without a title" do
        before { render_inline(described_class.new(message: message, theme: theme)) }

        it "does not render a title" do
          expect(notification_container).not_to have_css("h3")
        end

        it "renders only the message with the primary text style" do
          message_element = notification_container.find("p")
          expect(message_element).to have_text(message)
          expect(message_element['class']).to include(*theme_data.title_text_classes.split)
        end
      end
    end
  end
end
