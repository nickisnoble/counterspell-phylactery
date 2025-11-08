# Phlex v2 Features - Implementation Guide

This document outlines Phlex v2 features and their implementation status in our codebase.

## ✅ Implemented Features

### 1. **Kits** (v2 - Out of Beta)
**Status:** ✅ Fully implemented

Kits package components into modules for cleaner rendering syntax.

**Configuration:** `config/initializers/phlex.rb`
```ruby
module Components
  extend Phlex::Kit  # Makes Components a Kit
end
```

**Usage:** `app/views/base.rb`
```ruby
class Views::Base < Components::Base
  include Components  # Makes all components available without namespace prefix
end
```

**Example:**
```ruby
# Before: render Components::TraitCard.new(trait: trait)
# After:  TraitCard(trait: trait)
```

### 2. **Fragment Caching**
**Status:** ✅ Implemented for all card components

Caches component output for better performance. Automatically includes deployment timestamp, class name, method, and line number in cache keys.

**Setup:** `app/components/base.rb`
```ruby
def cache_store
  Rails.cache  # Uses Rails.cache by default
end
```

**Implemented in:**
- `TraitCard` - Caches using `@trait` (busts on trait update)
- `HeroCard` - Caches using `[@hero, @hero.traits]` (busts on hero or trait changes)
- `PageCard` - Caches using `@page` (busts on page update)

**Example:**
```ruby
def view_template
  cache(@trait) do
    article do
      # ... expensive rendering ...
    end
  end
end
```

### 3. **render? Method**
**Status:** ✅ Implemented for FlashMessage

Encapsulates conditional rendering logic within components rather than in consumers.

**Example:** `app/components/flash_message.rb`
```ruby
class Components::FlashMessage < Views::Base
  def render?
    @message.present?  # Only renders if message exists
  end

  def view_template
    p { @message }
  end
end
```

**Usage:**
```ruby
# Component automatically skips rendering if render? returns false
render FlashMessage.new(message: alert, type: :alert)
```

### 4. **Snippets (Private Methods)**
**Status:** ✅ Already using throughout codebase

Snippets are regular private methods that break down complex templates.

**Example:** `app/views/layouts/application_layout.rb`
```ruby
def view_template(&block)
  body do
    render_header    # Snippet
    render_flash     # Snippet
    yield_content(&block)
    render_footer    # Snippet
  end
end

private

def render_header
  header { # ... }
end
```

### 5. **v2 Syntax**
**Status:** ✅ Using correct v2 syntax

- ✅ `view_template` (not `template`)
- ✅ `raw` (not `unsafe_raw`)
- ✅ `render` accepts blocks (no `yield_content` needed)

## 🚫 Not Using (By Design)

### 1. **Streaming**
**Status:** Not implemented (not needed)

**Why:** The documentation states streaming offers limited benefits unless "views spend significant amounts of time waiting on asynchronous IO." Our views are fast and don't need this.

**When to reconsider:** If we add external API calls or heavy async operations in views.

### 2. **Fragments** (Experimental)
**Status:** Not implemented (experimental feature)

**Why:** This is still an experimental feature for selective rendering of template sections. We don't currently have a use case for this level of granular rendering.

**When to reconsider:** If we need to render only specific parts of complex components (e.g., updating just a card's header via Turbo).

## 📚 Best Practices We Follow

### 1. **Component Composition**
We render components from within other components using the Kit syntax:
```ruby
TraitCard(trait: trait)
HeroCard(hero: hero)
```

### 2. **Block Handling**
We properly handle blocks in components:
```ruby
def view_template(&block)
  article(class: "paper", &block)  # Passes block to HTML element
end
```

### 3. **Rails Integration**
- ✅ Using `include Phlex::Rails::Layout` for layouts
- ✅ Properly including Rails helpers (Routes, LinkTo, FormWith, etc.)
- ✅ Registering custom helpers (Current, authenticated?, etc.)

### 4. **Conditional Rendering**
We use `render?` to encapsulate conditional logic:
```ruby
# Good: Logic in component
render FlashMessage.new(message: alert, type: :alert)

# Avoid: Logic in consumer
# if alert.present?
#   render FlashMessage.new(message: alert, type: :alert)
# end
```

## 🎯 Future Considerations

### Testing Components
Consider implementing Nokogiri-based component testing:

```ruby
def test_trait_card
  output = render Components::TraitCard.new(trait: traits(:one))
  doc = Nokogiri::HTML5.fragment(output)

  assert_equal "Human", doc.css("h3").text
  assert doc.css(".abilities").present?
end
```

### More render? Usage
Look for opportunities to extract conditional rendering into components:
- Navigation items that show based on permissions
- Section headers that only show when content exists
- Feature flags

### Cache Optimization
Monitor cache hit rates and consider:
- Using `low_level_cache` for manual cache key control
- Adding cache versioning for complex dependencies
- Fragment caching at the view level for expensive pages

## 📖 Resources

- [Phlex Documentation](https://www.phlex.fun/)
- [Phlex v2 Upgrade Guide](https://www.phlex.fun/miscellaneous/v2-upgrade)
- [Phlex Kits](https://www.phlex.fun/components/kits)
- [Phlex Caching](https://www.phlex.fun/components/caching)
- [Phlex GitHub](https://github.com/phlex-ruby/phlex)

## Version Info

- **Phlex:** 2.3.1
- **Phlex-Rails:** 2.3.1
- **Rails:** 8.0

---

Last updated: 2025-01-08
