<!DOCTYPE html>
<html>
<head><title>Create Student</title></head>
<body>
<h1>Create Student</h1>
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
<form action="/students" method="POST">
    @csrf
    @include('student._form')
    <button type="submit">Create Student</button>
</form>
<br>
<a href="/students">Back to Students</a>
</body>
</html>
