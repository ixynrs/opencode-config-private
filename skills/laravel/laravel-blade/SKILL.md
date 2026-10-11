# Laravel Blade

You are an expert in Laravel's Blade templating engine. This skill ensures views are clean, reusable, and maintainable using Laravel 12+ best practices.

## Blade Components

Prefer Blade Components over partials for reusability:

```php
// Creating
php artisan make:component Alert

// Usage
<x-alert type="error" :message="$message" />
```

- Use anonymous components (`app/View/Components/`) for small, app-specific components.
- Use class-based components for complex logic and properties.

## Component Best Practices

- Pass data to components via attributes (`:prop` for variables, `prop` for strings).
- Use the `@props` directive to declare data variables:

```blade
@props(['type' => 'info', 'message'])

<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>
```

- Use slots for wrapper-style components:
  ```blade
  <x-card>
      <x-slot name="title">My Title</x-slot>
      Content here
  </x-card>
  ```

## Attribute Bag

Merge default attributes with user-provided ones using `$attributes->merge()`:

```blade
<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>
```

Pass additional HTML attributes easily:

```blade
<x-alert type="error" :message="$message" class="mb-4"/>
<!-- Renders: <div class="alert alert-error mb-4">...</div> -->
```

## Avoiding Raw PHP

- **Never write raw PHP** inside Blade templates.
- Use Blade directives (`@if`, `@foreach`, `@forelse`, etc.).
- Use Laravel's `@json()` helper instead of `json_encode()`.

## Layouts

Use one of these approaches:

1. **Component-based (Recommended)**: Create a master layout component
   ```blade
   <x-layout>
       <x-slot name="content">
           Page content
       </x-slot>
   </x-layout>
   ```

2. **Traditional extends**:
   ```blade
   @extends('layouts.app')
   
   @section('content')
   @endsection
   ```

## Keeping Logic Out of Views

- Views should only contain presentation logic.
- Move complex data transformations to:
  - View Composers (for sharing data across views)
  - Eloquent API Resources (for API response formatting)
  - Controller or Service layer

## Directives Reference

- `@auth`, `@guest` for authentication checks
- `@can`, `@cannot` for authorization
- `@error('field')` for validation errors
- `@csrf` for cross-site request forgery protection
- `@method('PUT')` for method spoofing
- `@json()` for encoding data to JSON safely

## Componentless Views

For pages that don't need a full component, use plain Blade files in `resources/views/`.
