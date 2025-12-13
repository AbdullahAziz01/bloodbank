# Firebase Setup Guide for Email Authentication

This guide will help you configure Firebase Console to enable email verification and deploy security rules for your Blood Bank application.

## Prerequisites

- Firebase project already created and connected to your Flutter app
- Firebase Console access: https://console.firebase.google.com

## Step 1: Enable Email Verification Templates

1. **Navigate to Authentication Settings**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project
   - Click on **Authentication** in the left sidebar
   - Click on the **Templates** tab

2. **Configure Email Verification Template**
   - Find **Email address verification** in the template list
   - Click the **Edit** (pencil) icon
   - Customize the template (optional):
     - **Sender name**: BloodBank App
     - **Subject**: Verify your email for BloodBank
     - **Email body**: You can customize the message
   - Click **Save**

3. **Configure Password Reset Template**
   - Find **Password reset** in the template list
   - Click the **Edit** (pencil) icon
   - Customize the template (optional):
     - **Sender name**: BloodBank App
     - **Subject**: Reset your BloodBank password
     - **Email body**: You can customize the message
   - Click **Save**

## Step 2: Deploy Firestore Security Rules

1. **Open Firestore Database**
   - In Firebase Console, click on **Firestore Database** in the left sidebar
   - Click on the **Rules** tab

2. **Deploy Security Rules**
   - Copy the contents of `firestore.rules` file from your project
   - Paste it into the rules editor in Firebase Console
   - Click **Publish** to deploy the rules

3. **Verify Rules Are Active**
   - After publishing, you should see a success message
   - The rules will be active immediately

## Step 3: Test Email Verification

### Test Registration Flow

1. **Run Your App**
   ```bash
   flutter run
   ```

2. **Register a New Account**
   - Use a real email address you can access
   - Fill in all registration fields
   - Submit the form

3. **Check Your Email**
   - You should receive a verification email within 1-2 minutes
   - Check spam folder if not in inbox
   - Click the verification link

4. **Login with Verified Account**
   - Return to the app
   - Login with your credentials
   - You should be able to access the dashboard

### Test Unverified Email Login

1. **Register Another Account**
   - Use a different email
   - Complete registration

2. **Try to Login Without Verifying**
   - Don't click the verification link
   - Try to login immediately
   - You should see a dialog: "Email Verification Required"

3. **Test Resend Verification**
   - Click "Resend Email" in the dialog
   - Check your inbox for a new verification email

### Test Password Reset

1. **Go to Login Screen**
   - Click "Forgot Password?"

2. **Enter Your Email**
   - Use a registered email address
   - Submit the form

3. **Check Your Email**
   - You should receive a password reset email
   - Click the reset link
   - Set a new password

4. **Login with New Password**
   - Return to the app
   - Login with your new password

## Step 4: Verify Security Rules

### Test via Firebase Console

1. **Try to Create Data Without Verification**
   - Go to Firestore Database > Data
   - Try to manually add a document to `bloodRequests` collection
   - If rules are working, you should see an error

2. **Verify After Email Verification**
   - Verify your email
   - Try to create a blood request from the app
   - It should succeed

### Test Role-Based Access

1. **Try to Modify Another User's Data**
   - Login as User A
   - Note User A's UID
   - In Firebase Console, try to modify User B's document
   - Should be denied by security rules

2. **Try to Change Role**
   - Login to your app
   - Try to update your user document's `role` field via Firebase Console
   - Should be denied (role cannot be changed after creation)

## Common Issues and Solutions

### Issue: Not Receiving Verification Emails

**Solutions:**
1. Check spam/junk folder
2. Verify email address is correct
3. In Firebase Console > Authentication > Settings, check if email provider is enabled
4. Add your domain to authorized domains (Authentication > Settings > Authorized domains)

### Issue: "Email already in use" Error

**Solution:**
- The email is already registered
- Use the password reset flow to recover the account
- Or use a different email address

### Issue: Security Rules Denying Access

**Solutions:**
1. Verify email is verified (check in Firebase Console > Authentication > Users)
2. Check that rules are published correctly
3. Ensure user document exists in Firestore with correct structure
4. Check browser console for detailed error messages

### Issue: Verification Link Not Working

**Solutions:**
1. Make sure you're using the latest link (old links expire)
2. Check if email verification is enabled in Firebase Console
3. Try resending the verification email

## Firebase Console Quick Links

- **Authentication**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication
- **Firestore Rules**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/rules
- **Email Templates**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication/emails

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

## Security Best Practices

1. **Never disable email verification** in production
2. **Regularly review security rules** to ensure they're up to date
3. **Monitor authentication logs** for suspicious activity
4. **Use strong password requirements** (already enforced: minimum 6 characters)
5. **Enable multi-factor authentication** for admin accounts
6. **Regularly backup Firestore data**

## Next Steps

After completing this setup:

1. ✅ Email verification is enforced
2. ✅ Password reset is available
3. ✅ Security rules protect your data
4. ✅ Only verified users can access the app

Your Blood Bank application now has secure, production-ready authentication!

## Support

If you encounter any issues:
1. Check Firebase Console logs
2. Review Flutter console output
3. Verify all steps in this guide are completed
4. Check Firebase documentation: https://firebase.google.com/docs/auth
