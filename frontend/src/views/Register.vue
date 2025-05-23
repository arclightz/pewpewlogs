<template>
  <div
    id="page-container"
    class="mx-auto flex min-h-screen w-full min-w-80 flex-col bg-gray-900 text-gray-100"
  >
    <main id="page-content" class="flex max-w-full flex-auto flex-col">
      <div
        class="relative mx-auto flex min-h-screen w-full max-w-10xl items-center justify-center overflow-hidden p-4 lg:p-8"
      >
        <section class="w-full max-w-xl py-6">
          <header class="mb-10 text-center">
            <h1 class="mb-2 inline-flex items-center gap-2 text-2xl font-bold">
              <svg
                class="hi-mini hi-cube-transparent inline-block size-5 text-blue-400"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path fill-rule="evenodd" d="M9.638 1.093a.75.75 0 01.724 0l2 1.104a.75.75 0 11-.724 1.313L10 2.607l-1.638.903a.75.75 0 11-.724-1.313l2-1.104zM5.403 4.287a.75.75 0 01-.295 1.019l-.805.444.805.444a.75.75 0 01-.724 1.314L3.5 7.02v.73a.75.75 0 01-1.5 0v-2a.75.75 0 01.388-.657l1.996-1.1a.75.75 0 011.019.294zm9.194 0a.75.75 0 011.02-.295l1.995 1.101A.75.75 0 0118 5.75v2a.75.75 0 01-1.5 0v-.73l-.884.488a.75.75 0 11-.724-1.314l.806-.444-.806-.444a.75.75 0 01-.295-1.02zM7.343 8.284a.75.75 0 011.02-.294L10 8.893l1.638-.903a.75.75 0 11.724 1.313l-1.612.89v1.557a.75.75 0 01-1.5 0v-1.557l-1.612-.89a.75.75 0 01-.295-1.019zM2.75 11.5a.75.75 0 01.75.75v1.557l1.608.887a.75.75 0 01-.724 1.314l-1.996-1.101A.75.75 0 012 14.25v-2a.75.75 0 01.75-.75zm14.5 0a.75.75 0 01.75.75v2a.75.75 0 01-.388.657l-1.996 1.1a.75.75 0 11-.724-1.313l1.608-.887V12.25a.75.75 0 01.75-.75zm-7.25 4a.75.75 0 01.75.75v.73l.888-.49a.75.75 0 01.724 1.313l-2 1.104a.75.75 0 01-.724 0l-2-1.104a.75.75 0 11.724-1.313l.888.49v-.73a.75.75 0 01.75-.75z" clip-rule="evenodd"/>
              </svg>
              <span>Pewpewlogs</span> </h1>
            <h2 class="text-sm font-medium text-gray-400">
              Create your account to start logging sessions
            </h2>
          </header>
          <div
            class="flex flex-col overflow-hidden rounded-lg bg-gray-800 shadow-xs text-gray-100"
          >
            <div class="grow p-5 md:px-16 md:py-12">
              <form @submit.prevent="handleRegister" class="space-y-6">
                <div class="space-y-1">
                  <label for="name" class="inline-block text-sm font-medium">Name</label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    v-model="name"
                    placeholder="Enter your name"
                    class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                    required
                  />
                </div>
                <div class="space-y-1">
                  <label for="email" class="inline-block text-sm font-medium">Email</label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    v-model="email"
                    placeholder="Enter your email"
                    class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                    required
                  />
                </div>
                <div class="space-y-1">
                  <label for="password" class="inline-block text-sm font-medium">Password</label>
                  <input
                    type="password"
                    id="password"
                    name="password"
                    v-model="password"
                    placeholder="Enter your password"
                    class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                    required
                  />
                </div>
                <div v-if="errorMessage" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
                  {{ errorMessage }}
                </div>
                <div v-if="successMessage" class="bg-green-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
                  {{ successMessage }}
                </div>
                <div>
                  <button
                    type="submit"
                    class="inline-flex w-full items-center justify-center gap-2 rounded-lg border border-blue-700 bg-blue-700 px-6 py-3 leading-6 font-semibold text-white hover:border-blue-600 hover:bg-blue-600 focus:ring-3 focus:ring-blue-400/50 active:border-blue-700 active:bg-blue-700"
                    :disabled="isRegistering"
                  >
                    <svg
                      class="hi-mini hi-arrow-uturn-right inline-block size-5 opacity-50"
                      xmlns="http://www.w3.org/2000/svg"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M12.207 2.232a.75.75 0 00.025 1.06l4.146 3.958H6.375a5.375 5.375 0 000 10.75H9.25a.75.75 0 000-1.5H6.375a3.875 3.875 0 010-7.75h10.003l-4.146 3.957a.75.75 0 001.036 1.085l5.5-5.25a.75.75 0 000-1.085l-5.5-5.25a.75.75 0 00-1.06.025z"
                        clip-rule="evenodd"
                      />
                    </svg>
                    <span>{{ isRegistering ? 'Registering...' : 'Sign Up' }}</span>
                  </button>
                  </div>
              </form>
            </div>
            <div
              class="grow bg-gray-700 p-5 text-center text-sm"
            >
              Already have an account?
              <router-link
                to="/login"
                class="font-medium text-blue-400 hover:text-blue-300"
                >Sign in</router-link
              >
            </div>
          </div>
          <div class="mt-6 text-center text-sm text-gray-400">
            Powered by
            <a href="#" class="font-medium text-blue-400 hover:text-blue-300">Pewpewlogs</a>
          </div>
          </section>
        </div>
    </main>
    </div>
  </template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import authService from '../services/authService';

const name = ref('');
const email = ref('');
const password = ref('');
const errorMessage = ref('');
const successMessage = ref('');
const isRegistering = ref(false);
const router = useRouter();

const handleRegister = async () => {
  errorMessage.value = '';
  successMessage.value = '';
  isRegistering.value = true;

  try {
    const response = await authService.register(name.value, email.value, password.value);
    successMessage.value = response.message;
    console.log('Registration success:', response); // Keep console log for debugging
  } catch (error) {
    console.error('Registration failed:', error);
    errorMessage.value = error.message || 'An unexpected error occurred during registration.';
  } finally {
    isRegistering.value = false;
  }
};
</script>
