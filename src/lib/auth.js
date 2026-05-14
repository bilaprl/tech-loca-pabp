import { supabase } from "./supabaseClient";

// REGISTER
export const registerUser = async (email, password, name) => {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: name,
      },
    },
  });

  return { data, error };
};

// LOGIN EMAIL
export const loginUser = async (email, password) => {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  return { data, error };
};

// Di dalam lib/auth.js fungsi loginWithGoogle
export const loginWithGoogle = async () => {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: window.location.origin, // Ini akan memaksa balik ke domain asal dengan session
    },
  })
  return { data, error }
}

// LOGOUT
export const logoutUser = async () => {
  await supabase.auth.signOut();
};