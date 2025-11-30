# Quick Fix - Delete Test Account in Firebase

## Option 1: Delete User in Firebase Console (30 seconds)

1. Go to: https://console.firebase.google.com
2. Select **LifePlanner** project
3. Click **Authentication** → **Users** tab
4. Find the user with email `test@example.com`
5. Click the **3 dots** (⋮) on the right
6. Click **"Delete user"**
7. Confirm

**Now you can create a new account with that email!**

---

## Option 2: Set a Known Password (Proper Fix)

I'll add a debug feature to reset to a known password.

### In Firebase Console:
1. Authentication → Users
2. Click on the user
3. Click **"Reset password"**
4. Set a temporary password: `Test123!`
5. Now you can sign in with `test@example.com` / `Test123!`

---

## Option 3: Just Use a Different Email (Quickest)

In the app:
1. Click "Sign Up"
2. Email: `jay@lifeplanner.com`
3. Password: `Test123!`
4. Name: Jay
5. Sign up

**This takes 10 seconds and you're in!**

---

## My Recommendation:

**Delete the test user in Firebase** (Option 1) so you have a clean slate. Then create one account with credentials you'll remember:

- Email: `jay@lifeplanner.com`
- Password: `Test123!`

Takes 40 seconds total. Then we can properly test!

---

**Which option do you prefer?** I'd say delete the user in Firebase Console (Option 1) - it's the cleanest!

