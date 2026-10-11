# Laravel PHPUnit Testing

You are an expert in Laravel testing using PHPUnit. This skill ensures tests are reliable, fast, and comprehensive using Laravel 12+ best practices.

## Test Structure

Use Laravel's built-in test scaffolding:
```bash
php artisan make:test UserTest
# or for Feature tests
php artisan make:test UserTest --feature
```

## Test Traits

Use appropriate traits for database handling:

```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserTest extends TestCase
{
    use RefreshDatabase; // Best for most tests - wraps in transaction
    
    // ...
}
```

- `RefreshDatabase`: Migrates fresh database for each test using transactions (fastest, recommended).
- `DatabaseMigrations`: Migrates once, rolls back after (slower).
- `DatabaseTransactions`: Wraps tests in database transactions (requires existing database).

## Test Types

1. **Feature Tests** (HTTP):
   - Test HTTP endpoints, middleware, authentication
   - Use `$this->get()`, `$this->post()`, etc.
   - Assert response status, content, JSON structure
   - **Rule**: Each test should make only one request

2. **Unit Tests**:
   - Test isolated classes, methods, business logic
   - Mock external dependencies

## HTTP Testing

```php
public function test_user_can_be_created(): void
{
    $response = $this->postJson('/api/users', [
        'name' => 'John',
        'email' => 'john@example.com',
    ]);

    $response->assertStatus(201)
             ->assertJsonStructure(['id', 'name', 'email']);
}

public function test_application_returns_successful_response(): void
{
    $response = $this->get('/');
    $response->assertStatus(200);
}
```

## Authentication Testing

Use `actingAs()` to simulate authenticated users:

```php
public function test_authenticated_user_can_view_dashboard(): void
{
    $user = User::factory()->create();

    $response = $this->actingAs($user)
        ->withSession(['banned' => false])
        ->get('/dashboard');

    $response->assertStatus(200);
}
```

## Model Factories

Use factories for test data:

```php
// Define in database/factories/
User::factory()->create();
User::factory()->count(5)->create();
User::factory()->create(['name' => 'Custom']);
```

## Assertions

Use meaningful assertions:

```php
$this->assertDatabaseHas('users', ['email' => 'test@example.com']);
$this->assertDatabaseMissing('users', ['email' => 'fake@example.com']);
$this->assertTrue($user->isActive());
$this->assertEquals(expected, actual);
$this->assertRedirect('/expected-route');
$this->assertSessionHas('key');
```

## Faking External Requests

Fake external HTTP requests during testing:

```php
Http::fake([
    'api.twitter.com/*' => Http::response(['data' => 'mock'], 200),
]);
```

## Running Tests

```bash
# Run all tests
php artisan test

# Run specific test file
php artisan test --filter=UserTest

# Run with coverage (requires Xdebug)
php artisan test --coverage
```

## Best Practices

- One assertion per test is ideal, but multiple related assertions are acceptable.
- Test edge cases and error conditions, not just happy paths.
- Use `withoutMiddleware()` or `withoutJobs()` to isolate tests when needed.
- Each test should be independent and not rely on other tests.
- Use descriptive test names: `test_user_can_create_post()`, `test_validation_fails_for_missing_email()`
