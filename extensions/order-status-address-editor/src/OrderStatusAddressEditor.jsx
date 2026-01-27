import '@shopify/ui-extensions/preact';
import {render} from "preact";
import Modal from "./Modal.jsx";

function Extension() {
  return (
    <>
      <s-button command="--show" commandFor="address-editor-modal">
        {shopify.i18n.translate("buttons.editAddress")}
      </s-button>
      <Modal />
    </>
  );
}

export default async () => {
  render(<Extension />, document.body);
};
