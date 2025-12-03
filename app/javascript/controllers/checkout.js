document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('payment-form');
  if (!form) return;

  const stripe = Stripe(form.dataset.publishableKey);
  const elements = stripe.elements();
  const card = elements.create('card', { hidePostalCode: true });
  card.mount('#card-element');

  const messageEl = document.getElementById('payment-message');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const response = await fetch('/checkout/create_payment_intent', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ order_id: form.dataset.orderId })
    });

    const data = await response.json();

    const { error, paymentIntent } = await stripe.confirmCardPayment(data.client_secret, {
      payment_method: {
        card: card,
        billing_details: {
          name: form.dataset.userName,
          email: form.dataset.userEmail
        }
      }
    });

    if (error) {
      messageEl.textContent = error.message;
    } else {
      messageEl.textContent = 'Payment succeeded!';
      window.location.href = '/checkout/success';
    }
  });
});
