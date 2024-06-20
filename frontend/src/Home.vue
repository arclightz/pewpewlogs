<template>
    <div class="min-h-screen flex flex-col md:flex-row items-center justify-center bg-gray-100">
      <div class="md:w-1/2 p-4">
        <h1 class="text-3xl md:text-5xl font-bold text-gray-800">Responsive Design</h1>
        <p class="mt-2 text-gray-600">
          This layout adjusts based on the screen size.
        </p>
      </div>
      <div class="md:w-1/2 p-4">
        <img src="https://via.placeholder.com/400" alt="Example" class="rounded-lg shadow-md">
      </div>
    </div>
  </template>

  <script>
  export default {
    name: 'ResponsiveExample',
  };
  </script>