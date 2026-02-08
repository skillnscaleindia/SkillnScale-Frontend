/*
  # ServiceConnect Database Schema

  ## Overview
  Complete database schema for ServiceConnect - a platform connecting home service providers with customers.

  ## New Tables

  ### 1. profiles
  Extended user profile information beyond auth.users
  - `id` (uuid, primary key, references auth.users)
  - `user_type` (text) - Either 'customer' or 'professional'
  - `full_name` (text)
  - `phone` (text)
  - `address` (text, nullable)
  - `profile_image_url` (text, nullable)
  - `bio` (text, nullable) - For professionals
  - `skills` (text[], nullable) - Array of skills for professionals
  - `hourly_rate` (numeric, nullable) - For professionals
  - `rating` (numeric, default 0)
  - `total_jobs` (integer, default 0)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 2. service_categories
  Predefined categories of services
  - `id` (uuid, primary key)
  - `name` (text)
  - `description` (text)
  - `icon` (text) - Icon name or URL
  - `created_at` (timestamptz)

  ### 3. service_requests
  Service requests created by customers
  - `id` (uuid, primary key)
  - `customer_id` (uuid, references profiles)
  - `professional_id` (uuid, references profiles, nullable)
  - `category_id` (uuid, references service_categories)
  - `title` (text)
  - `description` (text)
  - `location` (text)
  - `status` (text) - 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  - `scheduled_date` (timestamptz, nullable)
  - `price` (numeric, nullable)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 4. reviews
  Reviews and ratings for completed services
  - `id` (uuid, primary key)
  - `service_request_id` (uuid, references service_requests)
  - `reviewer_id` (uuid, references profiles)
  - `reviewee_id` (uuid, references profiles)
  - `rating` (integer) - 1-5
  - `comment` (text, nullable)
  - `created_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Profiles: Users can read all profiles, but only update their own
  - Service Requests: Customers can create and view their own requests; professionals can view all pending requests
  - Reviews: Anyone can read reviews; only customers who completed a service can create reviews

  ## Important Notes
  1. All tables use UUID for primary keys
  2. RLS policies ensure data isolation and security
  3. Timestamps are automatically managed
  4. Foreign key constraints maintain data integrity
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  user_type text NOT NULL CHECK (user_type IN ('customer', 'professional')),
  full_name text NOT NULL,
  phone text,
  address text,
  profile_image_url text,
  bio text,
  skills text[],
  hourly_rate numeric,
  rating numeric DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  total_jobs integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create service_categories table
CREATE TABLE IF NOT EXISTS service_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text,
  icon text,
  created_at timestamptz DEFAULT now()
);

-- Create service_requests table
CREATE TABLE IF NOT EXISTS service_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  professional_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  category_id uuid NOT NULL REFERENCES service_categories(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL,
  location text NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'in_progress', 'completed', 'cancelled')),
  scheduled_date timestamptz,
  price numeric,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_request_id uuid NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reviewee_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_profiles_user_type ON profiles(user_type);
CREATE INDEX IF NOT EXISTS idx_service_requests_customer ON service_requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_professional ON service_requests(professional_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_status ON service_requests(status);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee ON reviews(reviewee_id);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Anyone can view profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Service categories policies (read-only for all authenticated users)
CREATE POLICY "Anyone can view service categories"
  ON service_categories FOR SELECT
  TO authenticated
  USING (true);

-- Service requests policies
CREATE POLICY "Customers can view their own requests"
  ON service_requests FOR SELECT
  TO authenticated
  USING (
    auth.uid() = customer_id OR 
    auth.uid() = professional_id OR
    (status = 'pending' AND EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'professional'
    ))
  );

CREATE POLICY "Customers can create service requests"
  ON service_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = customer_id AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'customer')
  );

CREATE POLICY "Customers can update their own requests"
  ON service_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = customer_id)
  WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Professionals can accept requests"
  ON service_requests FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'professional')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'professional')
  );

-- Reviews policies
CREATE POLICY "Anyone can view reviews"
  ON reviews FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Service participants can create reviews"
  ON reviews FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = reviewer_id AND
    EXISTS (
      SELECT 1 FROM service_requests 
      WHERE id = service_request_id 
      AND status = 'completed'
      AND (customer_id = auth.uid() OR professional_id = auth.uid())
    )
  );

-- Insert default service categories
INSERT INTO service_categories (name, description, icon) VALUES
  ('Plumbing', 'Fix leaks, install fixtures, drain cleaning', 'plumbing'),
  ('Electrical', 'Wiring, lighting, electrical repairs', 'electrical'),
  ('Carpentry', 'Furniture assembly, repairs, custom woodwork', 'carpentry'),
  ('Cleaning', 'Home cleaning, deep cleaning, move-out cleaning', 'cleaning'),
  ('Painting', 'Interior and exterior painting', 'painting'),
  ('HVAC', 'Heating, ventilation, air conditioning services', 'hvac'),
  ('Landscaping', 'Lawn care, gardening, outdoor maintenance', 'landscaping'),
  ('Appliance Repair', 'Fix refrigerators, washers, dryers, etc.', 'appliance')
ON CONFLICT (name) DO NOTHING;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_service_requests_updated_at ON service_requests;
CREATE TRIGGER update_service_requests_updated_at
  BEFORE UPDATE ON service_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
