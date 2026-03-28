-- Varsity App Database Setup (Fixed Version)
-- Run this in your Supabase SQL Editor

-- Create users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    display_name TEXT,
    avatar_url TEXT,
    auth_provider TEXT CHECK (auth_provider IN ('apple', 'google', 'email')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_follows table for team following functionality
CREATE TABLE IF NOT EXISTS public.user_follows (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    school_id UUID REFERENCES public.schools(id) ON DELETE CASCADE NOT NULL,
    followed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notifications_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure a user can only follow a school once
    UNIQUE(user_id, school_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_follows_user_id ON public.user_follows(user_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_school_id ON public.user_follows(school_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Enable Row Level Security on new tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_follows ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for user_follows table
CREATE POLICY "Users can view their own follows" ON public.user_follows
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own follows" ON public.user_follows
    FOR ALL USING (auth.uid() = user_id);

-- Function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, display_name, auth_provider)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        CASE 
            WHEN NEW.app_metadata->>'provider' = 'apple' THEN 'apple'
            WHEN NEW.app_metadata->>'provider' = 'google' THEN 'google'
            ELSE 'email'
        END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update last_login timestamp
CREATE OR REPLACE FUNCTION public.update_last_login()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.users 
    SET last_login = NOW()
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update last_login on auth
DROP TRIGGER IF EXISTS on_auth_user_login ON auth.users;
CREATE TRIGGER on_auth_user_login
    AFTER UPDATE OF last_sign_in_at ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.update_last_login();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.user_follows TO authenticated;
GRANT SELECT ON public.schools TO anon, authenticated;
GRANT SELECT ON public.teams TO anon, authenticated;
GRANT SELECT ON public.games TO anon, authenticated;
