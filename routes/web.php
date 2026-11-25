<?php

use App\Http\Controllers\CourseController;
use App\Http\Controllers\StudentController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/students');

// One line each: creates the 7 standard CRUD routes with names like students.index
Route::resource('students', StudentController::class);
Route::resource('courses', CourseController::class);
