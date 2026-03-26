<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Polyculy - Sign Up</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="/assets/css/polyculy.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
    <div class="auth-bg">
        <i class="fas fa-heart floating-heart" style="left:10%; top:15%;"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>
        <i class="fas fa-heart floating-heart"></i>

        <div class="auth-card" style="max-width:480px;">
            <div class="auth-logo">
                <svg width="50" height="50" viewBox="0 0 40 40">
                    <defs>
                        <linearGradient id="hg1" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#7C3AED"/><stop offset="100%" style="stop-color:#EC4899"/>
                        </linearGradient>
                        <linearGradient id="hg2" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" style="stop-color:#EC4899"/><stop offset="100%" style="stop-color:#C4B5FD"/>
                        </linearGradient>
                    </defs>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#hg1)" transform="translate(2,5) scale(0.8)"/>
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="url(#hg2)" transform="translate(12,8) scale(0.8)" opacity="0.8"/>
                </svg>
                <h1>Join Polyculy</h1>
                <p class="tagline">You'll need a licence code to get started</p>
            </div>

            <div id="signupError" class="alert alert-danger d-none"></div>
            <div id="signupSuccess" class="alert alert-success d-none"></div>

            <form id="signupForm" onsubmit="return doSignup();">
                <div class="mb-3">
                    <label for="licenceCode" class="form-label">Licence Code</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-key text-purple"></i></span>
                        <input type="text" class="form-control" id="licenceCode" placeholder="POLY-XXXX-XXX" required>
                        <button type="button" class="btn btn-polyculy-outline" onclick="validateLicence()">Verify</button>
                    </div>
                    <div id="licenceStatus" class="form-text"></div>
                </div>
                <div class="mb-3">
                    <label for="displayName" class="form-label">Display Name</label>
                    <input type="text" class="form-control" id="displayName" placeholder="How others will see you" required>
                </div>
                <div class="mb-3">
                    <label for="signupEmail" class="form-label">Email</label>
                    <input type="email" class="form-control" id="signupEmail" placeholder="you@example.com" required>
                </div>
                <div class="row mb-3">
                    <div class="col">
                        <label for="signupPassword" class="form-label">Password</label>
                        <input type="password" class="form-control" id="signupPassword" minlength="6" required>
                    </div>
                    <div class="col">
                        <label for="confirmPassword" class="form-label">Confirm</label>
                        <input type="password" class="form-control" id="confirmPassword" minlength="6" required>
                    </div>
                </div>
                <div class="mb-3">
                    <label for="timezoneId" class="form-label">Timezone</label>
                    <select class="form-select" id="timezoneId">
                        <option value="America/New_York">Eastern (New York)</option>
                        <option value="America/Chicago">Central (Chicago)</option>
                        <option value="America/Denver">Mountain (Denver)</option>
                        <option value="America/Los_Angeles">Pacific (Los Angeles)</option>
                        <option value="Europe/London">GMT (London)</option>
                        <option value="Europe/Paris">CET (Paris)</option>
                        <option value="Asia/Tokyo">JST (Tokyo)</option>
                        <option value="Australia/Sydney">AEST (Sydney)</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-polyculy w-100 py-2 mb-3" id="signupBtn">
                    <i class="fas fa-user-plus me-2"></i>Create Account
                </button>
            </form>

            <div class="text-center">
                <a href="/index.cfm" class="text-decoration-none" style="color: var(--pc-primary);">
                    <small>Already have an account? <strong>Sign in</strong></small>
                </a>
            </div>
        </div>
    </div>

    <script>
    function validateLicence() {
        var code = $('#licenceCode').val().trim();
        if (!code) return;
        $.getJSON('/api/licences.cfm?action=validate&code=' + encodeURIComponent(code), function(r) {
            var data = r.DATA || r.data || {};
            if (data.VALID || data.valid) {
                $('#licenceStatus').html('<span class="text-success"><i class="fas fa-check-circle"></i> Valid licence</span>');
            } else {
                $('#licenceStatus').html('<span class="text-danger"><i class="fas fa-times-circle"></i> Invalid or used code</span>');
            }
        });
    }

    function doSignup() {
        $('#signupError').addClass('d-none');
        if ($('#signupPassword').val() !== $('#confirmPassword').val()) {
            $('#signupError').removeClass('d-none').text('Passwords do not match');
            return false;
        }
        var $btn = $('#signupBtn');
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-2"></i>Creating...');

        $.ajax({
            url: '/api/auth.cfm?action=signup',
            method: 'POST',
            data: {
                licence_code: $('#licenceCode').val(),
                display_name: $('#displayName').val(),
                email: $('#signupEmail').val(),
                password: $('#signupPassword').val(),
                timezone_id: $('#timezoneId').val()
            },
            dataType: 'json',
            success: function(resp) {
                if (resp.SUCCESS || resp.success) {
                    window.location.href = resp.REDIRECT || resp.redirect || '/views/calendar/setup.cfm';
                } else {
                    $('#signupError').removeClass('d-none').text(resp.MESSAGE || resp.message);
                    $btn.prop('disabled', false).html('<i class="fas fa-user-plus me-2"></i>Create Account');
                }
            },
            error: function() {
                $('#signupError').removeClass('d-none').text('Connection error');
                $btn.prop('disabled', false).html('<i class="fas fa-user-plus me-2"></i>Create Account');
            }
        });
        return false;
    }
    </script>
</body>
</html>
