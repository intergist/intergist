/**
 * TaskForge - Core JavaScript
 * jQuery + DataTables + Chosen + Bootstrap integration
 */

var TaskForge = (function($) {
    'use strict';

    // ----- Utility Functions -----

    function statusBadge(status) {
        var cls = {
            'To Do':       'badge-todo',
            'In Progress': 'badge-inprogress',
            'In Review':   'badge-inreview',
            'Done':        'badge-done',
            'Blocked':     'badge-blocked'
        };
        return '<span class="badge badge-status ' + (cls[status] || 'bg-secondary') + '">' + status + '</span>';
    }

    function priorityBadge(priority) {
        var cls = {
            'Low':      'badge-low',
            'Medium':   'badge-medium',
            'High':     'badge-high',
            'Critical': 'badge-critical'
        };
        return '<span class="badge badge-status ' + (cls[priority] || 'bg-secondary') + '">' + priority + '</span>';
    }

    function projectStatusBadge(status) {
        var cls = {
            'Active':    'badge-active',
            'On Hold':   'badge-onhold',
            'Completed': 'badge-completed',
            'Archived':  'badge-archived'
        };
        return '<span class="badge badge-status ' + (cls[status] || 'bg-secondary') + '">' + status + '</span>';
    }

    function avatarHtml(name, color, size) {
        size = size || 'sm';
        var initials = name ? name.split(' ').map(function(w){ return w[0]; }).join('').toUpperCase() : '?';
        return '<span class="avatar-' + size + '" style="background:' + (color || '#4F46E5') + '">' + initials + '</span>';
    }

    function formatDate(d) {
        if (!d || d === '') return '&mdash;';
        var dt = new Date(d);
        if (isNaN(dt.getTime())) return d;
        return dt.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    }

    function tagsHtml(tags) {
        if (!tags || tags === '') return '';
        return tags.split(',').map(function(t) {
            return '<span class="tag-pill">' + $.trim(t) + '</span>';
        }).join(' ');
    }

    function showToast(message, type) {
        type = type || 'success';
        var icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
        var bg = type === 'success' ? '#059669' : '#DC2626';
        var toastHtml = '<div class="position-fixed top-0 end-0 p-3" style="z-index:9999">' +
            '<div class="toast show align-items-center text-white border-0" style="background:' + bg + '">' +
            '<div class="d-flex"><div class="toast-body"><i class="fas ' + icon + ' me-2"></i>' + message + '</div>' +
            '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>' +
            '</div></div></div>';
        var $t = $(toastHtml).appendTo('body');
        setTimeout(function() { $t.fadeOut(300, function() { $(this).remove(); }); }, 3000);
    }

    // ----- API Helpers -----

    function apiGet(endpoint, params) {
        return $.ajax({ url: endpoint, data: params || {}, dataType: 'json' });
    }

    function apiPost(endpoint, data) {
        return $.ajax({ url: endpoint, method: 'POST', data: data, dataType: 'json' });
    }

    // Recursively lowercase all keys in object/array (Lucee returns UPPERCASE keys)
    function lowercaseKeys(obj) {
        if (Array.isArray(obj)) return obj.map(lowercaseKeys);
        if (obj && typeof obj === 'object') {
            var out = {};
            Object.keys(obj).forEach(function(k) { out[k.toLowerCase()] = lowercaseKeys(obj[k]); });
            return out;
        }
        return obj;
    }

    // ----- Public API -----
    return {
        lk: lowercaseKeys,
        statusBadge: statusBadge,
        priorityBadge: priorityBadge,
        projectStatusBadge: projectStatusBadge,
        avatarHtml: avatarHtml,
        formatDate: formatDate,
        tagsHtml: tagsHtml,
        showToast: showToast,
        apiGet: apiGet,
        apiPost: apiPost
    };

})(jQuery);

// Initialize Chosen dropdowns and DataTables on document ready
$(document).ready(function() {
    // Initialize all Chosen selects
    $('.chosen-select').chosen({ width: '100%', allow_single_deselect: true });

    // Close sidebar on mobile when clicking outside
    $(document).on('click', function(e) {
        if ($(window).width() < 992) {
            if (!$(e.target).closest('#sidebar, .btn-dark').length) {
                $('#sidebar').removeClass('show');
            }
        }
    });
});
