import React, { useState } from 'react';
import { Mail, Phone, MapPin, CheckCircle } from 'lucide-react';

interface ContactProps {
  props: {
    title?: string;
    description?: string;
    formId?: string;
    email?: string;
    phone?: string;
    address?: string;
  };
  styles?: Record<string, any>;
}

export const Contact: React.FC<ContactProps> = ({ props, styles = {} }) => {
  const [formData, setFormData] = useState({ name: '', email: '', message: '' });
  const [status, setStatus] = useState<'idle' | 'submitting' | 'submitted' | 'error'>('idle');

  const bgClass = styles.background === 'surface' ? 'bg-surface' : 'bg-default';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!props.formId) {
      // Demo submit
      setStatus('submitted');
      return;
    }

    setStatus('submitting');
    try {
      const res = await fetch(`/api/v1/forms/${props.formId}/submit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });
      if (res.ok) {
        setStatus('submitted');
      } else {
        setStatus('error');
      }
    } catch {
      setStatus('error');
    }
  };

  return (
    <div className={`section ${bgClass}`} id="contact">
      <div className="container">
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
            gap: '3.5rem',
          }}
        >
          {/* Info Side */}
          <div>
            <h2 className="text-h2" style={{ marginBottom: '1.25rem' }}>
              {props.title || 'Get in Touch'}
            </h2>
            {props.description && (
              <p className="text-body" style={{ fontSize: '1.1rem', marginBottom: '2.5rem' }}>
                {props.description}
              </p>
            )}

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              {props.email && (
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <Mail size={22} color="var(--color-primary)" />
                  <a href={`mailto:${props.email}`} className="text-body" style={{ fontWeight: 500 }}>
                    {props.email}
                  </a>
                </div>
              )}
              {props.phone && (
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <Phone size={22} color="var(--color-primary)" />
                  <span className="text-body" style={{ fontWeight: 500 }}>
                    {props.phone}
                  </span>
                </div>
              )}
              {props.address && (
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <MapPin size={22} color="var(--color-primary)" />
                  <span className="text-body" style={{ fontWeight: 500 }}>
                    {props.address}
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* Form Side */}
          <div className="card">
            {status === 'submitted' ? (
              <div style={{ textAlign: 'center', padding: '2rem 1rem' }}>
                <CheckCircle size={48} color="#10B981" style={{ margin: '0 auto 1rem auto' }} />
                <h3 className="text-h3" style={{ marginBottom: '0.5rem' }}>Thank You!</h3>
                <p className="text-body">Your message has been sent successfully. We will get back to you shortly.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                <div>
                  <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 600, fontSize: '0.9rem' }}>
                    Full Name
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                    style={{
                      width: '100%',
                      padding: '0.75rem 1rem',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid rgba(0,0,0,0.15)',
                      fontSize: '1rem',
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 600, fontSize: '0.9rem' }}>
                    Email Address
                  </label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={e => setFormData({ ...formData, email: e.target.value })}
                    style={{
                      width: '100%',
                      padding: '0.75rem 1rem',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid rgba(0,0,0,0.15)',
                      fontSize: '1rem',
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 600, fontSize: '0.9rem' }}>
                    Message
                  </label>
                  <textarea
                    rows={4}
                    required
                    value={formData.message}
                    onChange={e => setFormData({ ...formData, message: e.target.value })}
                    style={{
                      width: '100%',
                      padding: '0.75rem 1rem',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid rgba(0,0,0,0.15)',
                      fontSize: '1rem',
                      resize: 'vertical',
                    }}
                  />
                </div>

                {status === 'error' && (
                  <div style={{ color: '#EF4444', fontSize: '0.9rem' }}>
                    Failed to send message. Please try again.
                  </div>
                )}

                <button
                  type="submit"
                  disabled={status === 'submitting'}
                  className="btn btn-primary"
                  style={{ width: '100%', marginTop: '0.5rem' }}
                >
                  {status === 'submitting' ? 'Sending...' : 'Send Message'}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
