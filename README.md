# Kanso (簡素)

A rigorously crafted component library for modern Rails applications, built on a philosophy of radical simplicity.

Kanso (簡素) is a Japanese design principle valuing clarity and the elimination of the non-essential. This library is the embodiment of that idea, providing a set of foundational, rigorously tested components that are respectful guests in your application.

This README is the single source of truth. The best API is one that needs no explanation.

## Prerequisites

Kanso is designed to integrate seamlessly into a standard Rails 7+ application. Please ensure your application is configured with:

1.  **Hotwire (Turbo & Stimulus)**
2.  **Tailwind CSS** (via the `tailwindcss-rails` gem)

## Installation

1.  Add `gem "kanso"` to your `Gemfile`.
2.  Run `bundle install`.
3.  Run `bin/rails g kanso:install`.

This generator surgically and safely configures your application. It creates or modifies `tailwind.config.js` and updates your main stylesheet to be aware of Kanso's components and base styles without being destructive.

---

## Component Catalogue

Each component is a self-contained, Hotwire-aware ViewComponent styled with Tailwind CSS. Interactive components include their own lightweight Stimulus controllers, which are automatically registered by the installer.

---

### ButtonComponent

An abstraction for styled actions. It can render a simple tag (`<button>`, `<a>`) or, by leveraging Rails' `button_to` helper, generate a complete single-button form for server-side actions (`DELETE`, `PATCH`, etc.).

**1. Usage (Simple Tag)**

For links or client-side UI interactions.

```erb
<%# Renders a standard <button> %>
<%= render Kanso::ButtonComponent.new(theme: :primary) do %>
  Primary Action
<% end %>

<%# Renders an <a> tag %>
<%= render Kanso::ButtonComponent.new(tag: :a, href: dashboard_path) do %>
  Go to Dashboard
<% end %>
```

**2. Usage (Action Form)**

For any action requiring a form, like `DELETE`, `PATCH`, or `POST`.

```erb
<%# Generates a form with method: :delete %>
<%= render Kanso::ButtonComponent.new(theme: :danger, url: item_path(@item), method: :delete) do %>
  Delete Item
<% end %>
```

**Options**

*   `theme:` (`Symbol`): The style. Can be `:primary`, `:danger`, or `:default`. Defaults to `:default`.

*   **For Simple Tag Mode:**
    *   `tag:` (`Symbol`): The HTML tag. Can be `:button` or `:a`. Defaults to `:button`.
    *   `href:` (`String`): Required if `tag: :a` is used.

*   **For Action Form Mode:**
    *   `url:` (`String` | `UrlHelper`): **Activates `button_to` mode**. The URL the form will submit to.
    *   `method:` (`Symbol`): The HTTP method (e.g., `:delete`, `:patch`).

*All other HTML options (`id`, `data-*`, `form:`, etc.) are passed through to the underlying `<button>`, `<a>`, or `button_to` helper.*

---

### IconComponent

Renders a performant, inline SVG icon from the Kanso library.

**Usage:**
```erb
<%= render Kanso::IconComponent.new(name: "x-mark", class: "h-5 w-5 text-gray-500") %>
```

**Options:**
*   `name:` (`String`, **required**): The name of the icon file (without the `.svg` extension).
*   *All other HTML options (`class`, `aria-hidden`, etc.) are injected into the `<svg>` tag.*

**Available Icons:**

A complete list of all available icons can be found in the source code:➡️ **[View all available icons](https://github.com/santonero/kanso/tree/main/app/assets/images/kanso/icons)**

---

### NotificationComponent

Renders a dismissible notification panel.

**Usage:**

```erb
<%= render Kanso::NotificationComponent.new(theme: :success, message: "Your profile was updated.") %>
```

**Options:**
*   `message:` (`String`, **required**): The notification's content.
*   `title:` (`String`, optional): An optional title.
*   `theme:` (`Symbol`): The style. Can be `:success`, `:error`, `:warning`, or `:info`. Defaults to `:info`.

**Implementation Patterns:**

A notification is most effective when rendered dynamically into a fixed container.

1.  **Add a Global Container** to your layout. This will be the target for all notifications.

    *In `app/views/layouts/application.html.erb`:*
    ```erb
    <div id="notifications-container" class="fixed top-4 right-4 z-50 w-full max-w-sm flex flex-col space-y-4">
    </div>
    ```

2.  **Render from the Rails Flash:** For redirects, use the `flash:` hash to pass semantic keys that match the component's themes.

    *In a controller:*
    ```ruby
    redirect_to @post, flash: { success: "Post was successfully updated." }
    ```
    *In your layout (inside the container):*
    ```erb
    <% flash.each do |key, message| %>
      <%= render Kanso::NotificationComponent.new(theme: key, message: message) %>
    <% end %>
    ```

3.  **Render from a Turbo Stream:** Append directly to the container for dynamic updates.

    *In a `.turbo_stream.erb` view:*
    ```erb
    <%= turbo_stream.append "notifications-container" do %>
      <%= render Kanso::NotificationComponent.new(theme: :success, message: "Review submitted.") %>
    <% end %>
    ```

---

### ModalComponent

Renders a fully self-contained modal dialog, including its trigger. It handles all open/close logic and is designed for both simple, static content and the lazy-loading of any dynamic content via Turbo Frames.

**Usage (Basic):**

For simple confirmation dialogs or modals with static content.

```erb
<%= render Kanso::ModalComponent.new do |modal| %>
  <% modal.with_trigger do %>
    <%= render Kanso::ButtonComponent.new(theme: :danger) do %>
      Delete Post
    <% end %>
  <% end %>

  <% modal.with_header(title: "Confirm Deletion") %>

  <p class="text-gray-600">
    Are you sure you want to delete this post? This action cannot be undone.
  </p>

  <% modal.with_footer do %>
    <%= render Kanso::ButtonComponent.new(data: { action: "kanso--modal#close" }) do %>
      Cancel
    <% end %>
    <%= render Kanso::ButtonComponent.new(
          theme: :danger,
          url: post_path(@post),
          method: :delete
        ) do %>
      Yes, Delete It
    <% end %>
  <% end %>
<% end %>
```

**Recommended Pattern (Lazy-Loading Content):**

For a superior user experience, lazy-load the modal's body inside a Turbo Frame. This example covers the entire workflow, from rendering the form to handling a successful submission.

**1. Render the Modal with a Turbo Frame**

```erb
<%= render Kanso::ModalComponent.new do |modal| %>
  <% modal.with_trigger do %>
    <%= render Kanso::ButtonComponent.new(theme: :primary) do %>
      New Product
    <% end %>
  <% end %>

  <% modal.with_header(title: "New Product") %>

  <%= turbo_frame_tag "modal_form", src: new_product_path, loading: :lazy do %>
    <%= render Kanso::FormFieldSkeletonComponent.new(fields: 2) %>
  <% end %>

  <% modal.with_footer do %>
    <%= render Kanso::ButtonComponent.new(data: { action: "kanso--modal#close" }) do %>
      Cancel
    <% end %>
    <%= render Kanso::ButtonComponent.new(theme: :primary, type: :submit, form: "new_product_form") do %>
      Create
    <% end %>
  <% end %>
<% end %>
```

**2. Handle Successful Submissions**

When a form inside a Turbo Frame succeeds, a standard `redirect_to` is trapped. The Kanso pattern uses a custom Turbo Stream action to break out of the modal and perform a full-page visit, letting Turbo Drive handle the flash message naturally.

*First, teach Turbo the `redirect` action in your `application.js`:*
```javascript
// app/javascript/application.js

// ...

// Teaches Turbo a new "redirect" action that performs a full-page visit.
Turbo.StreamActions.redirect = function() {
  Turbo.visit(this.target);
}
```

*Next, in your controller, set the flash and respond to the `turbo_stream` format:*
```ruby
# app/controllers/products_controller.rb
def create
  @product = Product.new(product_params)
  if @product.save
    # Set the flash message that Turbo Drive will render on the next page.
    flash[:success] = "Product was successfully created."

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @product, flash: { success: "Product was successfully created." } }
    end
  else
    # On validation failure, Turbo re-renders the frame with errors automatically.
    render :new, status: :unprocessable_entity
  end
end
```

*Finally, create a stream view that sends the pure `redirect` command:*
```erb
<%# app/views/products/create.turbo_stream.erb %>
<%= turbo_stream.action "redirect", product_path(@product) %>
```

**Options:**
*   `size:` (`Symbol`, optional): The max-width. `:sm`, `:md`, `:lg`, `:xl`, `:xxl`. Defaults to `:lg`.

**Slots:**
*   `with_trigger`: **(Required)** The element that opens the modal. Takes a block.
*   `with_header(title:)`: (Optional) The modal header.
    *   `title:` (`String`, **required**): Text for the header.
*   `with_footer`: (Optional) A dedicated section for action buttons. Takes a block.
*   **`content` block:** The main content of the modal.

---

### FormFieldComponent

Renders a complete form field unit, including a label, input, help text, and dynamic validation error messages. Designed for seamless integration with Rails form builders.

**Usage:**
```erb
<%= form_with model: @user do |form| %>
  <%= render Kanso::FormFieldComponent.new(form: form, attribute: :name) %>
<% end %>
```

**Automatic Error Handling:**
The component automatically detects and displays validation errors from your model object (`form.object.errors`).

**Options:**
*   `form:` (`FormBuilder`, **required**): The Rails form builder instance.
*   `attribute:` (`Symbol`, **required**): The model attribute for the field.
*   `type:` (`Symbol`, optional): The input type method to call (e.g., `:text_field`, `:password_field`). Defaults to `:text_field`.
*   `placeholder:` (`String`, optional): Placeholder text for the input.
*   *All other HTML options are passed directly to the input field.*

**Slots:**
*   `with_help_text`: (Optional) Renders descriptive text below the input. Takes a block.

---

### FormFieldSkeletonComponent

Provides a loading state placeholder perfectly matched to the `FormFieldComponent`. It's essential for preventing layout shift within lazy-loaded `turbo_frame_tag`s.

**Usage:**

Use this as the initial content of a `turbo_frame_tag` while the real form is loading from the server.

```erb
<%= turbo_frame_tag "product_form", src: new_product_path, loading: :lazy, class: "w-full"  do %>
  <%# This is displayed instantly while the real form is loading. %>
  <%= render Kanso::FormFieldSkeletonComponent.new(fields: 2) %>
<% end %>
```

**Options:**
*   `fields:` (`Integer`, optional): The number of skeleton field rows to render. Defaults to `1`.

---

### DropdownComponent

Renders a dropdown menu with a trigger and a floating panel, handling all user interactions and edge cases.

**Usage:**
```erb
<%= render Kanso::DropdownComponent.new do |dropdown| %>
  <% dropdown.with_trigger do %>
    <%= render Kanso::ButtonComponent.new do %>
      <span>Options</span>
      <%= render Kanso::IconComponent.new(name: "chevron-down", class: "h-5 w-5") %>
    <% end %>
  <% end %>

  <div class="py-1" role="none">
    <a href="#" class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100" role="menuitem">Edit</a>
    <a href="#" class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100" role="menuitem">Duplicate</a>
  </div>
<% end %>
```

**Slots:**
*   `with_trigger`: **(Required)** The element that toggles the dropdown. Takes a block.
*   **`content` block:** The content of the floating panel, passed directly to the `render` call.

---

## Development

1.  Clone the repository.
2.  Run `bundle install`.
3.  Run `bundle exec rspec` to execute the test suite.

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).