# Laravel Eloquent

You are an expert in Laravel's Eloquent ORM. This skill ensures database interactions are secure, efficient, and maintainable using Laravel 12+ best practices.

## Mass Assignment Protection

Always protect against mass assignment vulnerabilities:

```php
// Option 1: Define fillable
protected $fillable = ['name', 'email', 'password'];

// Option 2: Define guarded (prefer empty array for total protection)
protected $guarded = [];
```

Never leave both `$fillable` and `$guarded` undefined.

## Query Optimization (N+1 Prevention)

- **Always use eager loading** when accessing relationships to prevent N+1 queries:
  ```php
  $books = Book::with('author')->get();

  foreach ($books as $book) {
      echo $book->author->name; // Only 2 queries total
  }
  ```
- Use nested eager loading for deep relationships:
  ```php
  $users = User::with(['posts.comments.user'])->get();
  ```
- Use constrained eager loading:
  ```php
  $users = User::with(['posts' => function ($query) {
      $query->where('published', true)->orderBy('created_at', 'desc');
  }])->get();
  ```

## Lazy Loading vs Eager Loading

- Accessing relationships as properties triggers lazy loading (separate query per record).
- Lazy loading is disabled in production/debug mode to catch N+1 issues.
- If you need a relationship on a single model, use `load()` after fetching:
  ```php
  $user = User::find($id);
  $user->load('posts');
  ```

## Relationship Methods

Use relationship methods for complex queries instead of lazy loading:

```php
$publishedPosts = $user->posts()
    ->where('published', true)
    ->orderBy('created_at', 'desc')
    ->get();
```

## Database Transactions

Wrap multiple database operations in transactions to ensure data integrity:

```php
DB::transaction(function () {
    $order->update(['status' => 'processing']);
    $order->items()->delete();
});
```

## Query Scopes

Use local query scopes for reusable query logic:

```php
public function scopeActive($query)
{
    return $query->where('status', 'active');
}

// Usage
User::active()->get();
```

## Pagination

Always use pagination for large datasets:
```php
User::paginate(15);
// or
User::simplePaginate(15);
```

## Collections

Leverage Eloquent Collection methods for data manipulation:
- `->pluck('name')` to get array of values
- `->keyBy('id')` to index by key
- `->map()`, `->filter()`, `->sortBy()`

## Counting Related Models

Use `withCount()` to efficiently count relationships without additional queries:

```php
$users = User::withCount('posts')->get();
// Access via $user->posts_count
```

## Filtering by Relationships

```php
// Users who have at least one post
$users = User::has('posts')->get();

// Users with 5 or more posts
$users = User::has('posts', '>=', 5)->get();

// Filter by relationship conditions
$users = User::whereHas('posts', function ($query) {
    $query->where('published', true);
})->get();
```

## Many-to-Many Relationships

```php
// Attach roles
$user->roles()->attach(1);
$user->roles()->attach([1, 2, 3]);

// Sync (removes others)
$user->roles()->sync([1, 2]);

// Toggle
$user->roles()->toggle([1, 2]);

// With pivot data
$user->roles()->attach(1, ['assigned_by' => auth()->id()]);
```
