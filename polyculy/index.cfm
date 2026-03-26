<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Polyculy - Calendar that keeps up</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="/assets/css/polyculy.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
    <div class="auth-bg">
        <!-- Floating hearts -->
        <i class="fas fa-heart floating-heart" style="left:10%; top:15%;"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>

        <div class="auth-card">
            <div class="auth-logo">
                <svg width="60" height="60" viewBox="0 0 40 40">
                    <defs>
                        <linearGradient id="hg1" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#7C3AED"/>
                            <stop offset="100%" style="stop-color:#EC4899"/>
                        </linearGradient>
                        <linearGradient id="hg2" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#EC4899"/>
                            <stop offset="100%" style="stop-color:#C4B5FD"/>
                        </linearGradient>
                    </defs>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#hg1)" transform="translate(2,5) scale(0.8)"/>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#hg2)" transform="translate(12,8) scale(0.8)" opacity="0.8"/>
                </svg>
                <h1>Polyculy</h1>
                <p class="tagline">Calendar that keeps up</p>
            </div>

            <div id="loginError" class="alert alert-danger d-none" role="alert"></div>

            <form id="loginForm" onsubmit="return doLogin();">
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-envelope text-purple"></i></span>
                        <input type="email" class="form-control" id="email" name="email" placeholder="you@polyculy.app" required>
                    </div>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock text-purple"></i></span>
                        <input type="password" class="form-control" id="password" name="password" placeholder="Enter your password" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-polyculy w-100 py-2 mb-3" id="loginBtn">
                    <i class="fas fa-sign-in-alt me-2"></i>Sign In
                </button>
            </form>

            <div class="text-center">
                <a href="/views/auth/signup.cfm" class="text-decoration-none" style="color: var(--pc-primary);">
                    <small>Don't have an account? <strong>Sign up</strong></small>
                </a>
                <br>
                <a href="/views/auth/recovery.cfm" class="text-decoration-none text-muted">
                    <small>Forgot password?</small>
                </a>
            </div>

            <div class="mt-4 pt-3 border-top text-center">
                <small class="text-muted">Demo: <code>you@polyculy.app</code> / <code>demo123</code></small>
            </div>
        </div>
    </div>

    <script>
    function doLogin() {
        var $btn = $('#loginBtn');
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-2"></i>Signing in...');
        $('#loginError').addClass('d-none');

        $.ajax({
            url: '/api/auth.cfm?action=login',
            method: 'POST',
            data: { email: $('#email').val(), password: $('#password').val() },
            dataType: 'json',
            success: function(resp) {
                if (resp.SUCCESS || resp.success) {
                    var rd = resp.REDIRECT || resp.redirect;
                    window.location.href = rd || '/views/calendar/month.cfm';
                } else {
                    $('#loginError').removeClass('d-none').text(resp.MESSAGE || resp.message || 'Login failed');
                    $btn.prop('disabled', false).html('<i class="fas fa-sign-in-alt me-2"></i>Sign In');
                }
            },
            error: function() {
                $('#loginError').removeClass('d-none').text('Connection error. Please try again.');
                $btn.prop('disabled', false).html('<i class="fas fa-sign-in-alt me-2"></i>Sign In');
            }
        });
        return false;
    }
    </script>
</body>
</html>
