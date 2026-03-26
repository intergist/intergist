<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Polyculy - Password Recovery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="/assets/css/polyculy.css" rel="stylesheet">
</head>
<body>
    <div class="auth-bg">
        <i class="fas fa-heart floating-heart" style="left:10%; top:15%;"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>

        <div class="auth-card">
            <div class="auth-logo">
                <svg width="50" height="50" viewBox="0 0 40 40">
                    <defs>
                        <linearGradient id="hg1" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#7C3AED"/><stop offset="100%" style="stop-color:#EC4899"/>
                        </linearGradient>
                    </defs>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#hg1)" transform="translate(6,7) scale(0.9)"/>
                </svg>
                <h1>Password Recovery</h1>
                <p class="tagline">We'll help you get back in</p>
            </div>

            <div class="alert alert-info">
                <i class="fas fa-info-circle me-2"></i>
                <small>In this demo, password recovery sends a simulated reset. For demo accounts, the password is <code>demo123</code>.</small>
            </div>

            <form onsubmit="return false;">
                <div class="mb-3">
                    <label for="recoveryEmail" class="form-label">Email Address</label>
                    <input type="email" class="form-control" id="recoveryEmail" placeholder="you@polyculy.app" required>
                </div>
                <button type="submit" class="btn btn-polyculy w-100 py-2 mb-3" onclick="alert('In a production app, a reset link would be emailed. Demo password: demo123');">
                    <i class="fas fa-paper-plane me-2"></i>Send Reset Link
                </button>
            </form>

            <div class="text-center">
                <a href="/index.cfm" class="text-decoration-none" style="color: var(--pc-primary);">
                    <small><i class="fas fa-arrow-left me-1"></i>Back to Sign In</small>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
