-- Simple User Authentication Database
-- Clean, simple table structure for username/email/password authentication

-- Drop existing complex tables if you want to start fresh (OPTIONAL)
-- Uncomment these lines if you want to remove the old complex setup:
-- DROP TABLE IF EXISTS public.user_follows;
-- DROP TABLE IF EXISTS public.users;
-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- DROP TRIGGER IF EXISTS on_auth_user_login ON auth.users;
-- DROP FUNCTION IF EXISTS public.handle_new_user();
-- DROP FUNCTION IF EXISTS public.update_last_login();

-- Create simple users table - username, email, password + profile fields
CREATE TABLE IF NOT EXISTS public.simple_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    bio TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Simple validation constraints
    CONSTRAINT username_length CHECK (LENGTH(username) >= 4),
    CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9._-]+$'),
    CONSTRAINT email_format CHECK (email ~ '^[^@]+@[^@]+\.[^@]+$'),
    CONSTRAINT bio_length CHECK (LENGTH(bio) <= 500)
);

-- Create user_follows table for team following (links to simple_users)
CREATE TABLE IF NOT EXISTS public.simple_user_follows (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.simple_users(id) ON DELETE CASCADE NOT NULL,
    school_id UUID REFERENCES public.schools(id) ON DELETE CASCADE NOT NULL,
    followed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notifications_enabled BOOLEAN DEFAULT true,
    
    -- Ensure a user can only follow a school once
    UNIQUE(user_id, school_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_simple_users_username ON public.simple_users(username);
CREATE INDEX IF NOT EXISTS idx_simple_users_email ON public.simple_users(email);
CREATE INDEX IF NOT EXISTS idx_simple_user_follows_user_id ON public.simple_user_follows(user_id);
CREATE INDEX IF NOT EXISTS idx_simple_user_follows_school_id ON public.simple_user_follows(school_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.simple_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.simple_user_follows ENABLE ROW LEVEL SECURITY;

-- Simple RLS policies - allow all operations for now (you can restrict later)
DROP POLICY IF EXISTS "Allow all operations on simple_users" ON public.simple_users;
CREATE POLICY "Allow all operations on simple_users" ON public.simple_users
    FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all operations on simple_user_follows" ON public.simple_user_follows;
CREATE POLICY "Allow all operations on simple_user_follows" ON public.simple_user_follows
    FOR ALL USING (true);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.simple_users TO anon, authenticated;
GRANT ALL ON public.simple_user_follows TO anon, authenticated;
GRANT SELECT ON public.schools TO anon, authenticated;
GRANT SELECT ON public.teams TO anon, authenticated;
GRANT SELECT ON public.games TO anon, authenticated;
