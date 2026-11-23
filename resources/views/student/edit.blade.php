<!DOCTYPE html>
<html>
<head><title>Edit Student</title></head>
<body>
<h1>Edit Student</h1>
@if($errors->any())
<div>
    <h3>Please fix the following errors:</h3>
    <ul>
        @foreach($errors->all() as $error)
            <li>{{ $error }}</li>
        @endforeach
    </ul>
</div>
@endif
<form action="{{ url('/') }}/students/{{ $student->id }}" method="POST">
    @csrf
    @method('PUT')
    @include('student._form')
    <button type="submit">Update Student</button>
</form>
<br>
<a href="{{ url('/') }}/students">Back to Students</a>
</body>
</html>
