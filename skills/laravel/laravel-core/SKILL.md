# Laravel Core

You are an expert Laravel developer. This skill provides the foundational rules for building maintainable Laravel applications using modern Laravel 12+ conventions.

## Core Principles

- **Architecture**: Follow standard Laravel MVC pattern. Keep controllers thin - delegate complex logic to Service classes or Actions.
- **Routing**: Use explicit route definitions. Prefer `Route::resource()` for CRUD endpoints and `Route::apiResource()` for APIs.
- **Validation**: Always use Form Requests (`php artisan make:request`) for validation logic. Never validate in controllers directly.
- **PHP Version**: Assume PHP 8.2+ with strict typing (`declare(strict_types=1);`).
- **Configuration**: Use `.env` for configuration. Use `config()` helper to access settings throughout the app.

## Controller Guidelines

- Use resource controllers (`php artisan make:controller UserController --resource`).
- Use **Constructor Property Promotion** for dependency injection:
  ```php
  public function __construct(
      protected UserService $userService,
  ) {}
  ```
- Controllers should only:
  - Validate the request (via Form Request)
  - Call a Service/Action
  - Return a response (view, JSON, or redirect)
- Never put business logic directly in controllers.
- Always use return type hints (`: View`, `: JsonResponse`, etc.).

## Service/Action Pattern

For complex business logic, extract it into dedicated classes:
- **Service Classes**: Handle complex business operations and orchestration.
- **Action Classes** (optional): Use for single-method operations, popular in Laravel 11+.

## Dependency Injection

Laravel's service container automatically resolves dependencies. Use constructor injection in controllers, services, and other classes:

```php
public function __construct(
    protected AppleMusic $appleMusic,
) {}
```

## Routing Best Practices

- Use route model binding for implicit model injection:
  ```php
  Route::get('/users/{user}', [UserController::class, 'show']);
  // Controller method receives User model directly
  public function show(User $user) { ... }
  ```
- Use `Route::apiResource()` for API endpoints.
- Group routes with shared middleware using `Route::middleware()`.

## Error Handling

- Use Laravel's exception handling (`app/Exceptions/Handler.php`).
- Return consistent JSON structure for API errors.
- Use `abort()` for quick error responses with proper HTTP status codes.

## Artisan CLI

- Proactively use `php artisan` commands to generate boilerplate.
- Common generators:
  - `php artisan make:model -mcs` (model + migration + controller + seeder)
  - `php artisan make:request` (Form Request)
  - `php artisan make:seeder`, `php artisan make:factory`
  - `php artisan make:test` (Feature or Unit)
