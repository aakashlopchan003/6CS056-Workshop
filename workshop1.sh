#!/usr/bin/env bash
set -e
[ -f artisan ] || { echo "Run this from your Laravel project root."; exit 1; }

php artisan make:model Student -m
php artisan make:model Course -m

STU=$(ls database/migrations/*_create_students_table.php)
COU=$(ls database/migrations/*_create_courses_table.php)

cat > "$STU" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone');
            $table->text('address')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
PHP

cat > "$COU" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->unsignedInteger('duration');
            $table->decimal('fee', 10, 2);
            $table->enum('difficulty', ['Easy', 'Medium', 'Hard']);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
};
PHP

cat > app/Models/Student.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $fillable = ['name', 'email', 'phone', 'address', 'date_of_birth'];
}
PHP

cat > app/Models/Course.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    protected $fillable = ['name', 'description', 'duration', 'fee', 'difficulty', 'is_active'];

    protected $casts = ['is_active' => 'boolean'];
}
PHP

php artisan migrate

mkdir -p resources/views/student resources/views/course

ERRORS='@if($errors->any())
<div>
    <h3>Please fix the following errors:</h3>
    <ul>
        @foreach($errors->all() as $error)
            <li>{{ $error }}</li>
        @endforeach
    </ul>
</div>
@endif'

cat > resources/views/student/_form.blade.php <<'BLADE'
<div><label for="name">Name</label>
    <input type="text" id="name" name="name" value="{{ old('name', $student->name ?? '') }}"></div><br>
<div><label for="email">Email</label>
    <input type="email" id="email" name="email" value="{{ old('email', $student->email ?? '') }}"></div><br>
<div><label for="phone">Phone</label>
    <input type="text" id="phone" name="phone" value="{{ old('phone', $student->phone ?? '') }}"></div><br>
<div><label for="address">Address</label>
    <textarea id="address" name="address">{{ old('address', $student->address ?? '') }}</textarea></div><br>
<div><label for="date_of_birth">Date of Birth</label>
    <input type="date" id="date_of_birth" name="date_of_birth" value="{{ old('date_of_birth', isset($student) && $student->date_of_birth ? \Illuminate\Support\Carbon::parse($student->date_of_birth)->format('Y-m-d') : '') }}"></div><br>
BLADE

{ cat <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Create Student</title></head>
<body>
<h1>Create Student</h1>
BLADE
echo "$ERRORS"
cat <<'BLADE'
<form action="/students" method="POST">
    @csrf
    @include('student._form')
    <button type="submit">Create Student</button>
</form>
<br>
<a href="/students">Back to Students</a>
</body>
</html>
BLADE
} > resources/views/student/create.blade.php

{ cat <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Edit Student</title></head>
<body>
<h1>Edit Student</h1>
BLADE
echo "$ERRORS"
cat <<'BLADE'
<form action="/students/{{ $student->id }}" method="POST">
    @csrf
    @method('PUT')
    @include('student._form')
    <button type="submit">Update Student</button>
</form>
<br>
<a href="/students">Back to Students</a>
</body>
</html>
BLADE
} > resources/views/student/edit.blade.php

cat > resources/views/student/list.blade.php <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Students</title></head>
<body>
<h1>Students</h1>

@if(session('success'))
    <p>{{ session('success') }}</p>
@endif

<a href="/students/create">Create Student</a> | <a href="/courses">Courses</a>

<table border="1" cellpadding="10">
    <thead>
        <tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Actions</th></tr>
    </thead>
    <tbody>
    @forelse($students as $student)
        <tr>
            <td>{{ $student->id }}</td>
            <td>{{ $student->name }}</td>
            <td>{{ $student->email }}</td>
            <td>{{ $student->phone }}</td>
            <td>
                <a href="/students/{{ $student->id }}">View</a>
                <a href="/students/{{ $student->id }}/edit">Edit</a>
                <form action="/students/{{ $student->id }}" method="POST" style="display:inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit">Delete</button>
                </form>
            </td>
        </tr>
    @empty
        <tr><td colspan="5">No students found.</td></tr>
    @endforelse
    </tbody>
</table>
</body>
</html>
BLADE

cat > resources/views/student/detail.blade.php <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Student Details</title></head>
<body>
<h1>Student Details</h1>
@if(session('success'))
    <p>{{ session('success') }}</p>
@endif
<p><strong>ID:</strong> {{ $student->id }}</p>
<p><strong>Name:</strong> {{ $student->name }}</p>
<p><strong>Email:</strong> {{ $student->email }}</p>
<p><strong>Phone:</strong> {{ $student->phone }}</p>
<p><strong>Address:</strong> {{ $student->address }}</p>
<p><strong>Date of Birth:</strong> {{ $student->date_of_birth }}</p>
<a href="/students/{{ $student->id }}/edit">Edit Student</a>
<br>
<a href="/students">Back to Students</a>
</body>
</html>
BLADE

cat > resources/views/course/_form.blade.php <<'BLADE'
<div><label for="name">Name</label>
    <input type="text" id="name" name="name" value="{{ old('name', $course->name ?? '') }}"></div><br>
<div><label for="description">Description</label>
    <textarea id="description" name="description">{{ old('description', $course->description ?? '') }}</textarea></div><br>
<div><label for="duration">Duration (weeks)</label>
    <input type="number" id="duration" name="duration" min="1" value="{{ old('duration', $course->duration ?? '') }}"></div><br>
<div><label for="fee">Fee</label>
    <input type="number" step="0.01" min="0" id="fee" name="fee" value="{{ old('fee', $course->fee ?? '') }}"></div><br>
<div><label for="difficulty">Difficulty</label>
    <select id="difficulty" name="difficulty">
        @foreach(['Easy', 'Medium', 'Hard'] as $level)
            <option value="{{ $level }}" @selected(old('difficulty', $course->difficulty ?? '') === $level)>{{ $level }}</option>
        @endforeach
    </select></div><br>
<div>
    <input type="hidden" name="is_active" value="0">
    <label><input type="checkbox" name="is_active" value="1" @checked(old('is_active', $course->is_active ?? true))> Active</label>
</div><br>
BLADE

{ cat <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Create Course</title></head>
<body>
<h1>Create Course</h1>
BLADE
echo "$ERRORS"
cat <<'BLADE'
<form action="/courses" method="POST">
    @csrf
    @include('course._form')
    <button type="submit">Create Course</button>
</form>
<br>
<a href="/courses">Back to Courses</a>
</body>
</html>
BLADE
} > resources/views/course/create.blade.php

{ cat <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Edit Course</title></head>
<body>
<h1>Edit Course</h1>
BLADE
echo "$ERRORS"
cat <<'BLADE'
<form action="/courses/{{ $course->id }}" method="POST">
    @csrf
    @method('PUT')
    @include('course._form')
    <button type="submit">Update Course</button>
</form>
<br>
<a href="/courses">Back to Courses</a>
</body>
</html>
BLADE
} > resources/views/course/edit.blade.php

cat > resources/views/course/list.blade.php <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Courses</title></head>
<body>
<h1>Courses</h1>

@if(session('success'))
    <p>{{ session('success') }}</p>
@endif

<a href="/courses/create">Create Course</a> | <a href="/students">Students</a>

<table border="1" cellpadding="10">
    <thead>
        <tr><th>ID</th><th>Name</th><th>Duration (weeks)</th><th>Fee</th><th>Difficulty</th><th>Active</th><th>Actions</th></tr>
    </thead>
    <tbody>
    @forelse($courses as $course)
        <tr>
            <td>{{ $course->id }}</td>
            <td>{{ $course->name }}</td>
            <td>{{ $course->duration }}</td>
            <td>{{ $course->fee }}</td>
            <td>{{ $course->difficulty }}</td>
            <td>{{ $course->is_active ? 'Yes' : 'No' }}</td>
            <td>
                <a href="/courses/{{ $course->id }}">View</a>
                <a href="/courses/{{ $course->id }}/edit">Edit</a>
                <form action="/courses/{{ $course->id }}" method="POST" style="display:inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit">Delete</button>
                </form>
            </td>
        </tr>
    @empty
        <tr><td colspan="7">No courses found.</td></tr>
    @endforelse
    </tbody>
</table>
</body>
</html>
BLADE

cat > resources/views/course/detail.blade.php <<'BLADE'
<!DOCTYPE html>
<html>
<head><title>Course Details</title></head>
<body>
<h1>Course Details</h1>
@if(session('success'))
    <p>{{ session('success') }}</p>
@endif
<p><strong>ID:</strong> {{ $course->id }}</p>
<p><strong>Name:</strong> {{ $course->name }}</p>
<p><strong>Description:</strong> {{ $course->description }}</p>
<p><strong>Duration:</strong> {{ $course->duration }} weeks</p>
<p><strong>Fee:</strong> {{ $course->fee }}</p>
<p><strong>Difficulty:</strong> {{ $course->difficulty }}</p>
<p><strong>Active:</strong> {{ $course->is_active ? 'Yes' : 'No' }}</p>
<a href="/courses/{{ $course->id }}/edit">Edit Course</a>
<br>
<a href="/courses">Back to Courses</a>
</body>
</html>
BLADE

cat > routes/web.php <<'PHP'
<?php

use App\Models\Course;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Validation\Rule;

Route::get('/', function () {
    return redirect('/students');
});

/* ===================== STUDENTS ===================== */

Route::get('/students', function () {
    return view('student.list', ['students' => Student::all()]);
})->name('students.index');

Route::get('/students/create', function () {
    return view('student.create');
});

Route::post('/students', function (Request $request) {
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|max:255|unique:students,email',
        'phone' => 'required|string|max:20',
        'address' => 'nullable|string|max:500',
        'date_of_birth' => 'nullable|date',
    ]);

    $student = Student::create($validated);

    return redirect()->route('students.index')
        ->with('success', "Student {$student->name} created successfully!");
});

Route::get('/students/{id}', function ($id) {
    return view('student.detail', ['student' => Student::findOrFail($id)]);
});

Route::get('/students/{id}/edit', function ($id) {
    return view('student.edit', ['student' => Student::findOrFail($id)]);
});

Route::put('/students/{id}', function (Request $request, $id) {
    $student = Student::findOrFail($id);

    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => ['required', 'email', 'max:255', Rule::unique('students')->ignore($student->id)],
        'phone' => 'required|string|max:20',
        'address' => 'nullable|string|max:500',
        'date_of_birth' => 'nullable|date',
    ]);

    $student->update($validated);

    return redirect('/students/' . $student->id)
        ->with('success', 'Student updated successfully!');
});

Route::delete('/students/{id}', function ($id) {
    Student::findOrFail($id)->delete();

    return redirect('/students')->with('success', 'Student deleted successfully!');
});

/* ===================== COURSES ===================== */

$courseRules = [
    'name' => 'required|string|max:255',
    'description' => 'nullable|string|max:2000',
    'duration' => 'required|integer|min:1',
    'fee' => 'required|numeric|min:0',
    'difficulty' => ['required', Rule::in(['Easy', 'Medium', 'Hard'])],
    'is_active' => 'required|boolean',
];

Route::get('/courses', function () {
    return view('course.list', ['courses' => Course::all()]);
})->name('courses.index');

Route::get('/courses/create', function () {
    return view('course.create');
});

Route::post('/courses', function (Request $request) use ($courseRules) {
    $course = Course::create($request->validate($courseRules));

    return redirect()->route('courses.index')
        ->with('success', "Course {$course->name} created successfully!");
});

Route::get('/courses/{id}', function ($id) {
    return view('course.detail', ['course' => Course::findOrFail($id)]);
});

Route::get('/courses/{id}/edit', function ($id) {
    return view('course.edit', ['course' => Course::findOrFail($id)]);
});

Route::put('/courses/{id}', function (Request $request, $id) use ($courseRules) {
    $course = Course::findOrFail($id);
    $course->update($request->validate($courseRules));

    return redirect('/courses/' . $course->id)
        ->with('success', 'Course updated successfully!');
});

Route::delete('/courses/{id}', function ($id) {
    Course::findOrFail($id)->delete();

    return redirect('/courses')->with('success', 'Course deleted successfully!');
});
PHP

echo
echo "Done. Start the server with:  php artisan serve"
