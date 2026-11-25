<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $fillable = [
        'name',
        'email',
        'phone',
        'address',
        'date_of_birth',
    ];

    // Cast: date_of_birth becomes a date object, so we can call ->format() and ->age on it.
    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
        ];
    }

    // Accessor: a virtual attribute. $student->age works although there is no "age" column.
    protected function age(): Attribute
    {
        return Attribute::get(fn () => $this->date_of_birth?->age);
    }
}
