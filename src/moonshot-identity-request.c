/* moonshot-identity-request.c generated by valac 0.10.4, the Vala compiler
 * generated from moonshot-identity-request.vala, do not modify */


#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <stdlib.h>
#include <string.h>


#define TYPE_IDENTITY_REQUEST (identity_request_get_type ())
#define IDENTITY_REQUEST(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_IDENTITY_REQUEST, IdentityRequest))
#define IDENTITY_REQUEST_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_IDENTITY_REQUEST, IdentityRequestClass))
#define IS_IDENTITY_REQUEST(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_IDENTITY_REQUEST))
#define IS_IDENTITY_REQUEST_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_IDENTITY_REQUEST))
#define IDENTITY_REQUEST_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_IDENTITY_REQUEST, IdentityRequestClass))

typedef struct _IdentityRequest IdentityRequest;
typedef struct _IdentityRequestClass IdentityRequestClass;
typedef struct _IdentityRequestPrivate IdentityRequestPrivate;

#define TYPE_ID_CARD (id_card_get_type ())
#define ID_CARD(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_ID_CARD, IdCard))
#define ID_CARD_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_ID_CARD, IdCardClass))
#define IS_ID_CARD(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_ID_CARD))
#define IS_ID_CARD_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_ID_CARD))
#define ID_CARD_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_ID_CARD, IdCardClass))

typedef struct _IdCard IdCard;
typedef struct _IdCardClass IdCardClass;

#define TYPE_MAIN_WINDOW (main_window_get_type ())
#define MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_MAIN_WINDOW, MainWindow))
#define MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_MAIN_WINDOW, MainWindowClass))
#define IS_MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_MAIN_WINDOW))
#define IS_MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_MAIN_WINDOW))
#define MAIN_WINDOW_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_MAIN_WINDOW, MainWindowClass))

typedef struct _MainWindow MainWindow;
typedef struct _MainWindowClass MainWindowClass;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))
typedef struct _Block1Data Block1Data;

typedef void (*ReturnIdentityCallback) (IdentityRequest* request, void* user_data);
struct _IdentityRequest {
	GObject parent_instance;
	IdentityRequestPrivate * priv;
	IdCard* id_card;
	gboolean complete;
};

struct _IdentityRequestClass {
	GObjectClass parent_class;
};

struct _IdentityRequestPrivate {
	MainWindow* main_window;
	char* nai;
	char* password;
	char* certificate;
	ReturnIdentityCallback callback;
	gpointer callback_target;
	GDestroyNotify callback_target_destroy_notify;
};

struct _Block1Data {
	int _ref_count_;
	IdentityRequest * self;
	ReturnIdentityCallback cb;
	gpointer cb_target;
	GDestroyNotify cb_target_destroy_notify;
};


static gpointer identity_request_parent_class = NULL;

GType identity_request_get_type (void) G_GNUC_CONST;
GType id_card_get_type (void) G_GNUC_CONST;
GType main_window_get_type (void) G_GNUC_CONST;
#define IDENTITY_REQUEST_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_IDENTITY_REQUEST, IdentityRequestPrivate))
enum  {
	IDENTITY_REQUEST_DUMMY_PROPERTY
};
IdentityRequest* identity_request_new (MainWindow* main_window, const char* nai, const char* password, const char* certificate);
IdentityRequest* identity_request_construct (GType object_type, MainWindow* main_window, const char* nai, const char* password, const char* certificate);
void identity_request_set_callback (IdentityRequest* self, ReturnIdentityCallback cb, void* cb_target, GDestroyNotify cb_target_destroy_notify);
static void _lambda0_ (IdentityRequest* IdCard, Block1Data* _data1_);
static void __lambda0__return_identity_callback (IdentityRequest* request, gpointer self);
static Block1Data* block1_data_ref (Block1Data* _data1_);
static void block1_data_unref (Block1Data* _data1_);
gboolean identity_request_execute (IdentityRequest* self);
void main_window_select_identity (MainWindow* self, IdentityRequest* request);
void identity_request_return_identity (IdentityRequest* self, IdCard* id_card);
static void identity_request_finalize (GObject* obj);



static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


IdentityRequest* identity_request_construct (GType object_type, MainWindow* main_window, const char* nai, const char* password, const char* certificate) {
	IdentityRequest * self = NULL;
	MainWindow* _tmp0_;
	char* _tmp1_;
	char* _tmp2_;
	char* _tmp3_;
	g_return_val_if_fail (main_window != NULL, NULL);
	g_return_val_if_fail (nai != NULL, NULL);
	g_return_val_if_fail (password != NULL, NULL);
	g_return_val_if_fail (certificate != NULL, NULL);
	self = (IdentityRequest*) g_object_new (object_type, NULL);
	self->priv->main_window = (_tmp0_ = _g_object_ref0 (main_window), _g_object_unref0 (self->priv->main_window), _tmp0_);
	self->priv->nai = (_tmp1_ = g_strdup (nai), _g_free0 (self->priv->nai), _tmp1_);
	self->priv->password = (_tmp2_ = g_strdup (password), _g_free0 (self->priv->password), _tmp2_);
	self->priv->certificate = (_tmp3_ = g_strdup (certificate), _g_free0 (self->priv->certificate), _tmp3_);
	return self;
}


IdentityRequest* identity_request_new (MainWindow* main_window, const char* nai, const char* password, const char* certificate) {
	return identity_request_construct (TYPE_IDENTITY_REQUEST, main_window, nai, password, certificate);
}


static void _lambda0_ (IdentityRequest* IdCard, Block1Data* _data1_) {
	IdentityRequest * self;
	self = _data1_->self;
	g_return_if_fail (IdCard != NULL);
	_data1_->cb (IdCard, _data1_->cb_target);
}


static void __lambda0__return_identity_callback (IdentityRequest* request, gpointer self) {
	_lambda0_ (request, self);
}


static Block1Data* block1_data_ref (Block1Data* _data1_) {
	g_atomic_int_inc (&_data1_->_ref_count_);
	return _data1_;
}


static void block1_data_unref (Block1Data* _data1_) {
	if (g_atomic_int_dec_and_test (&_data1_->_ref_count_)) {
		_g_object_unref0 (_data1_->self);
		(_data1_->cb_target_destroy_notify == NULL) ? NULL : (_data1_->cb_target_destroy_notify (_data1_->cb_target), NULL);
		_data1_->cb = NULL;
		_data1_->cb_target = NULL;
		_data1_->cb_target_destroy_notify = NULL;
		g_slice_free (Block1Data, _data1_);
	}
}


void identity_request_set_callback (IdentityRequest* self, ReturnIdentityCallback cb, void* cb_target, GDestroyNotify cb_target_destroy_notify) {
	Block1Data* _data1_;
	ReturnIdentityCallback _tmp0_;
	g_return_if_fail (self != NULL);
	_data1_ = g_slice_new0 (Block1Data);
	_data1_->_ref_count_ = 1;
	_data1_->self = g_object_ref (self);
	_data1_->cb = cb;
	_data1_->cb_target = cb_target;
	_data1_->cb_target_destroy_notify = cb_target_destroy_notify;
	self->priv->callback = (_tmp0_ = __lambda0__return_identity_callback, ((self->priv->callback_target_destroy_notify == NULL) ? NULL : (self->priv->callback_target_destroy_notify (self->priv->callback_target), NULL), self->priv->callback = NULL, self->priv->callback_target = NULL, self->priv->callback_target_destroy_notify = NULL), self->priv->callback_target = block1_data_ref (_data1_), self->priv->callback_target_destroy_notify = block1_data_unref, _tmp0_);
	block1_data_unref (_data1_);
}


gboolean identity_request_execute (IdentityRequest* self) {
	gboolean result = FALSE;
	g_return_val_if_fail (self != NULL, FALSE);
	main_window_select_identity (self->priv->main_window, self);
	result = FALSE;
	return result;
}


void identity_request_return_identity (IdentityRequest* self, IdCard* id_card) {
	IdCard* _tmp0_;
	g_return_if_fail (self != NULL);
	g_return_if_fail (self->priv->callback != NULL);
	self->id_card = (_tmp0_ = _g_object_ref0 (id_card), _g_object_unref0 (self->id_card), _tmp0_);
	self->complete = TRUE;
	self->priv->callback (self, self->priv->callback_target);
}


static void identity_request_class_init (IdentityRequestClass * klass) {
	identity_request_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (IdentityRequestPrivate));
	G_OBJECT_CLASS (klass)->finalize = identity_request_finalize;
}


static void identity_request_instance_init (IdentityRequest * self) {
	self->priv = IDENTITY_REQUEST_GET_PRIVATE (self);
	self->id_card = NULL;
	self->complete = FALSE;
	self->priv->callback = NULL;
}


static void identity_request_finalize (GObject* obj) {
	IdentityRequest * self;
	self = IDENTITY_REQUEST (obj);
	_g_object_unref0 (self->id_card);
	_g_object_unref0 (self->priv->main_window);
	_g_free0 (self->priv->nai);
	_g_free0 (self->priv->password);
	_g_free0 (self->priv->certificate);
	(self->priv->callback_target_destroy_notify == NULL) ? NULL : (self->priv->callback_target_destroy_notify (self->priv->callback_target), NULL);
	self->priv->callback = NULL;
	self->priv->callback_target = NULL;
	self->priv->callback_target_destroy_notify = NULL;
	G_OBJECT_CLASS (identity_request_parent_class)->finalize (obj);
}


GType identity_request_get_type (void) {
	static volatile gsize identity_request_type_id__volatile = 0;
	if (g_once_init_enter (&identity_request_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (IdentityRequestClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) identity_request_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (IdentityRequest), 0, (GInstanceInitFunc) identity_request_instance_init, NULL };
		GType identity_request_type_id;
		identity_request_type_id = g_type_register_static (G_TYPE_OBJECT, "IdentityRequest", &g_define_type_info, 0);
		g_once_init_leave (&identity_request_type_id__volatile, identity_request_type_id);
	}
	return identity_request_type_id__volatile;
}



