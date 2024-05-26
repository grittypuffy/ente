import { ensure } from "@/utils/ensure";
import { wait } from "@/utils/promise";
import { changeEmail, sendOTTForEmailChange } from "@ente/accounts/api/user";
import { PAGES } from "@ente/accounts/constants/pages";
import { APP_HOMES } from "@ente/shared/apps/constants";
import type { PageProps } from "@ente/shared/apps/types";
import { VerticallyCentered } from "@ente/shared/components/Container";
import FormPaper from "@ente/shared/components/Form/FormPaper";
import FormPaperFooter from "@ente/shared/components/Form/FormPaper/Footer";
import FormPaperTitle from "@ente/shared/components/Form/FormPaper/Title";
import LinkButton from "@ente/shared/components/LinkButton";
import SubmitButton from "@ente/shared/components/SubmitButton";
import { LS_KEYS, getData, setData } from "@ente/shared/storage/localStorage";
import { Alert, Box, TextField } from "@mui/material";
import { Formik, type FormikHelpers } from "formik";
import { t } from "i18next";
import { useRouter } from "next/router";
import { useEffect, useState } from "react";
import { Trans } from "react-i18next";
import * as Yup from "yup";

function ChangeEmailPage({ appName, appContext }: PageProps) {
    const router = useRouter();

    useEffect(() => {
        const user = getData(LS_KEYS.USER);
        if (!user?.token) {
            router.push(PAGES.ROOT);
        }
    }, []);

    return (
        <VerticallyCentered>
            <FormPaper>
                <FormPaperTitle>{t("CHANGE_EMAIL")}</FormPaperTitle>
                <ChangeEmailForm appName={appName} appContext={appContext} />
            </FormPaper>
        </VerticallyCentered>
    );
}

export default ChangeEmailPage;

interface formValues {
    email: string;
    ott?: string;
}

function ChangeEmailForm({ appName }: PageProps) {
    const [loading, setLoading] = useState(false);
    const [ottInputVisible, setShowOttInputVisibility] = useState(false);
    const [email, setEmail] = useState<string | null>(null);
    const [showMessage, setShowMessage] = useState(false);
    const [success, setSuccess] = useState(false);

    const router = useRouter();

    const requestOTT = async (
        { email }: formValues,
        { setFieldError }: FormikHelpers<formValues>,
    ) => {
        try {
            setLoading(true);
            await sendOTTForEmailChange(email);
            setEmail(email);
            setShowOttInputVisibility(true);
            setShowMessage(true);
            // TODO: What was this meant to focus on? The ref referred to an
            // Form element that was removed. Is this still needed.
            // setTimeout(() => {
            //     ottInputRef.current?.focus();
            // }, 250);
        } catch (e) {
            setFieldError("email", t("EMAIl_ALREADY_OWNED"));
        }
        setLoading(false);
    };

    const requestEmailChange = async (
        { email, ott }: formValues,
        { setFieldError }: FormikHelpers<formValues>,
    ) => {
        try {
            setLoading(true);
            await changeEmail(email, ensure(ott));
            setData(LS_KEYS.USER, { ...getData(LS_KEYS.USER), email });
            setLoading(false);
            setSuccess(true);
            await wait(1000);
            goToApp();
        } catch (e) {
            setLoading(false);
            setFieldError("ott", t("INCORRECT_CODE"));
        }
    };

    const goToApp = () => {
        // TODO: Refactor the type of APP_HOMES to not require the ??
        router.push(APP_HOMES.get(appName) ?? "/");
    };

    return (
        <Formik<formValues>
            initialValues={{ email: "" }}
            validationSchema={
                ottInputVisible
                    ? Yup.object().shape({
                          email: Yup.string()
                              .email(t("EMAIL_ERROR"))
                              .required(t("REQUIRED")),
                          ott: Yup.string().required(t("REQUIRED")),
                      })
                    : Yup.object().shape({
                          email: Yup.string()
                              .email(t("EMAIL_ERROR"))
                              .required(t("REQUIRED")),
                      })
            }
            validateOnChange={false}
            validateOnBlur={false}
            onSubmit={!ottInputVisible ? requestOTT : requestEmailChange}
        >
            {({ values, errors, handleChange, handleSubmit }) => (
                <>
                    {showMessage && (
                        <Alert
                            color="success"
                            onClose={() => setShowMessage(false)}
                        >
                            <Trans
                                i18nKey="EMAIL_SENT"
                                components={{
                                    a: (
                                        <Box
                                            color="text.muted"
                                            component={"span"}
                                        />
                                    ),
                                }}
                                values={{ email }}
                            />
                        </Alert>
                    )}
                    <form noValidate onSubmit={handleSubmit}>
                        <VerticallyCentered>
                            <TextField
                                fullWidth
                                InputProps={{
                                    readOnly: ottInputVisible,
                                }}
                                type="email"
                                label={t("ENTER_EMAIL")}
                                value={values.email}
                                onChange={handleChange("email")}
                                error={Boolean(errors.email)}
                                helperText={errors.email}
                                autoFocus
                                disabled={loading}
                            />
                            {ottInputVisible && (
                                <TextField
                                    fullWidth
                                    type="text"
                                    label={t("ENTER_OTT")}
                                    value={values.ott}
                                    onChange={handleChange("ott")}
                                    error={Boolean(errors.ott)}
                                    helperText={errors.ott}
                                    disabled={loading}
                                />
                            )}
                            <SubmitButton
                                success={success}
                                sx={{ mt: 2 }}
                                loading={loading}
                                buttonText={
                                    !ottInputVisible
                                        ? t("SEND_OTT")
                                        : t("VERIFY")
                                }
                            />
                        </VerticallyCentered>
                    </form>

                    <FormPaperFooter
                        style={{
                            justifyContent: ottInputVisible
                                ? "space-between"
                                : "normal",
                        }}
                    >
                        {ottInputVisible && (
                            <LinkButton
                                onClick={() => setShowOttInputVisibility(false)}
                            >
                                {t("CHANGE_EMAIL")}?
                            </LinkButton>
                        )}
                        <LinkButton onClick={goToApp}>
                            {t("GO_BACK")}
                        </LinkButton>
                    </FormPaperFooter>
                </>
            )}
        </Formik>
    );
}
