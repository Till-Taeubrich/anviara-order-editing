import "@shopify/ui-extensions/preact";
import { useState, useEffect } from "preact/hooks";

const BACKEND_URL =
  shopify?.shop?.myshopifyDomain !== "dev-apptesting-store.myshopify.com"
    ? "https://orderediting.anviara.com"
    : "https://orderediting.anviara.dev";

const isGerman = shopify.localization?.language?.value?.isoCode === "de";

const FIELD_ROWS = [
  [
    {
      name: "firstName",
      label: shopify.i18n.translate("fields.firstName"),
      required: !isGerman,
    },
    {
      name: "lastName",
      label: shopify.i18n.translate("fields.lastName"),
      required: true,
    },
  ],
  [
    {
      name: "address1",
      label: shopify.i18n.translate("fields.address1"),
      required: true,
    },
  ],
  [
    {
      name: "address2",
      label: shopify.i18n.translate("fields.address2Optional"),
    },
  ],
  [
    {
      name: "zip",
      label: shopify.i18n.translate("fields.zip"),
      required: true,
    },
    {
      name: "city",
      label: shopify.i18n.translate("fields.city"),
      required: true,
    },
  ],
];

const ALL_FIELDS = FIELD_ROWS.flat();

function Modal() {
  const [address, setAddress] = useState({});
  const [originalAddress, setOriginalAddress] = useState({});
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [zipError, setZipError] = useState(null);
  const [success, setSuccess] = useState(false);
  const [statusPageUrl, setStatusPageUrl] = useState(null);

  useEffect(() => {
    const shippingAddr = shopify.shippingAddress?.value || {};
    const addressData = Object.fromEntries(
      ALL_FIELDS.map((f) => [f.name, shippingAddr[f.name] || ""]),
    );
    setAddress(addressData);
    setOriginalAddress(addressData);
  }, []);

  const isFormValid = ALL_FIELDS.filter((f) => f.required).every((f) =>
    address[f.name]?.trim(),
  );
  const hasChanges = ALL_FIELDS.some(
    (f) => address[f.name] !== originalAddress[f.name],
  );

  async function submitUpdate() {
    const sessionToken = await shopify.sessionToken.get();
    const orderId = shopify.order.value.id;
    const response = await fetch(
      `${BACKEND_URL}/api/shipping_address_updates`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${sessionToken}`,
        },
        body: JSON.stringify({
          order_id: orderId,
          address: Object.fromEntries(
            Object.entries(address).map(([k, v]) => [k, v.trim()]),
          ),
        }),
      },
    );
    return response.json();
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    setZipError(null);

    const maxRetryMs = 15000;
    const retryIntervalMs = 2000;
    const startTime = Date.now();

    try {
      let data;
      while (true) {
        data = await submitUpdate();

        if (data.success) {
          setSuccess(true);
          setStatusPageUrl(data.statusPageUrl);
          return;
        }

        if (data.retryable && Date.now() - startTime < maxRetryMs) {
          await new Promise((r) => setTimeout(r, retryIntervalMs));
          continue;
        }

        break;
      }

      const hasZipError = data.fieldErrors?.includes("zip");
      if (hasZipError) {
        setZipError(shopify.i18n.translate("errors.invalidZip"));
      }

      const bannerError = data.errors?.[0];
      if (bannerError) {
        setError(bannerError);
      } else if (!hasZipError) {
        setError(shopify.i18n.translate("errors.updateFailed"));
      }
    } catch {
      setError(shopify.i18n.translate("errors.networkError"));
    } finally {
      setIsLoading(false);
    }
  }

  const updateField = (name) => (e) => {
    setAddress((prev) => ({
      ...prev,
      [name]: e.target?.value ?? e.detail?.value ?? "",
    }));
    if (name === "zip") setZipError(null);
  };

  return (
    <s-modal
      id="address-editor-modal"
      heading={shopify.i18n.translate("editAddress")}
    >
      <s-form onSubmit={handleSubmit}>
        <s-grid gap="base">
          {FIELD_ROWS.map((row, i) =>
            row.length > 1 ? (
              <s-grid-item key={i}>
                <s-grid gridTemplateColumns="1fr 1fr" gap="base">
                  {row.map(({ name, label }) => (
                    <s-grid-item key={name}>
                      <s-text-field
                        label={label}
                        name={name}
                        value={address[name] || ""}
                        onInput={updateField(name)}
                        disabled={isLoading || success}
                        error={
                          name === "zip" ? zipError || undefined : undefined
                        }
                      />
                    </s-grid-item>
                  ))}
                </s-grid>
              </s-grid-item>
            ) : (
              <s-grid-item key={row[0].name}>
                <s-text-field
                  label={row[0].label}
                  name={row[0].name}
                  value={address[row[0].name] || ""}
                  onInput={updateField(row[0].name)}
                  disabled={isLoading || success}
                  error={
                    row[0].name === "zip" ? zipError || undefined : undefined
                  }
                />
              </s-grid-item>
            ),
          )}
          {error && (
            <s-grid-item>
              <s-text>{error}</s-text>
            </s-grid-item>
          )}
        </s-grid>
      </s-form>
      {!success ? (
        <>
          <s-button
            variant="secondary"
            command="--hide"
            commandFor="address-editor-modal"
            disabled={isLoading}
            slot="secondary-actions"
          >
            {shopify.i18n.translate("buttons.cancel")}
          </s-button>
          <s-button
            variant="primary"
            loading={isLoading}
            disabled={isLoading || !isFormValid || !hasChanges}
            onClick={handleSubmit}
            slot="primary-action"
          >
            {shopify.i18n.translate("buttons.save")}
          </s-button>
        </>
      ) : (
        <s-button variant="primary" href={statusPageUrl} slot="primary-action">
          {shopify.i18n.translate("buttons.continue")}
        </s-button>
      )}
    </s-modal>
  );
}

export default Modal;
